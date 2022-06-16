defmodule Aria.Accounts do
  @moduledoc """
  The Interface module for the every modules related Accounts
  """

  import Ecto.Query, warn: false
  alias Aria.Repo

  alias Aria.Accounts.{User, UserToken}
  alias Aria.Accounts.{Users, UserTokens, UserIdentities}
  alias Aria.Notifiers.UserNotifier

  defdelegate user_changeset(attrs \\ %{}), to: Users

  defdelegate change_user_registration(user, attrs \\ %{}), to: Users

  defdelegate get_user!(id), to: Users

  defdelegate get_user_by_email(email), to: Users

  defdelegate get_user_by_email_and_password(email, password), to: Users

  defdelegate register_user(attrs), to: Users

  def register_oauth_user(provider, user, token) do
    if existing_user = Users.get_user_by_provider(provider, user["email"]) do
      UserIdentities.update_oauth_token(provider, existing_user, token)
    else
      Users.register_oauth_user(provider, user, token)
    end
  end

  def deliver_one_time_passcode(%User{is_confirmed: true}, "confirm") do
    {:error, :already_confirmed}
  end

  def deliver_one_time_passcode(%User{} = user, context) do
    {one_time_pass, user_token} = UserTokens.build_one_time_passcode(user, context)
    Repo.insert!(user_token)
    UserNotifier.deliver_one_time_passcode(user, one_time_pass)
  end

  def validate_one_time_passcode(otp, context) do
    with {:ok, query} <- UserTokens.verify_otp_query(otp, context),
         [%User{} = user, %UserToken{} = token] <- Repo.one(query),
         true <- :pot.valid_hotp(otp, token.token, [{:last, 0}, {:token_length, 8}]) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def deliver_instruction_link(%User{} = user, context, url_fun)
      when is_function(url_fun, 1) do
    {encoded_token, user_token} = UserTokens.build_url_token(user, context)
    Repo.insert!(user_token)
    UserNotifier.deliver_instruction_link(user, url_fun.(encoded_token))
  end

  def validate_url_token(token, context) do
    with {:ok, query} <- UserTokens.verify_url_token_query(token, context),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  def generate_user_session_token(user) do
    {token, user_token} = UserTokens.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserTokens.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_session_token(token) do
    Repo.delete_all(UserTokens.token_and_context_query(token, "session"))
    :ok
  end

  def confirm_user(otp) do
    case validate_one_time_passcode(otp, "confirm") do
      {:ok, user} ->
        do_confirm_user(user)

      :error ->
        :error
    end
  end

  defp do_confirm_user(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserTokens.user_and_contexts_query(user, ["confirm"]))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end
end
