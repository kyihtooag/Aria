defmodule Aria.Accounts.UserTokens do
  @moduledoc """
  Context module for accounts_users_tokens.
  """

  import Ecto.Query

  alias Aria.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @session_validity_in_days 60

  ## Session Token

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  ## Session Token End

  ## One Time Passcode

  def build_one_time_passcode(user, context) do
    do_build_one_time_passcode(user, context, user.email)
  end

  defp do_build_one_time_passcode(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    secret = :crypto.hash(@hash_algorithm, token) |> Base.encode32()

    one_time_pass = :pot.hotp(secret, 1, token_length: 8)

    {
      one_time_pass,
      %UserToken{
        token: secret,
        otp: one_time_pass,
        context: context,
        sent_to: sent_to,
        user_id: user.id
      }
    }
  end

  ## One Time Passcode

  ## URL Token

  def build_url_token(user, context) do
    do_build_url_token(user, context, user.email)
  end

  defp do_build_url_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  ## URL Token End

  ## Verfication

  def verify_otp_query(otp, context) do
    days = days_for_context(context)

    query =
      from token in otp_and_context_query(otp, context),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
        select: [user, token]

    {:ok, query}
  end

  def verify_url_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  ## Verfication End

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("login"), do: @reset_password_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  def token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  def otp_and_context_query(otp, context) do
    from UserToken, where: [otp: ^otp, context: ^context]
  end

  def user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
