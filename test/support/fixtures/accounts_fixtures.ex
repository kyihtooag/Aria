defmodule Aria.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Aria.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "XW#xe4ud"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      password_confirmation: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Aria.Accounts.register_user()

    user
  end

  def extract_otp({:ok, captured_email}) do
    [_, _, _, token | _] = String.split(captured_email.text_body, "\n\n")
    token
  end

  def extract_url_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
