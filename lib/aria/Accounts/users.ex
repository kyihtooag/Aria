defmodule Aria.Accounts.Users do
  @moduledoc """
  Context module for User model.
  """

  import Ecto.Query, warn: false
  alias Aria.Repo

  alias Aria.Accounts.{User, UserIdentity, UserIdentities}

  def user_changeset(attrs \\ %{}) do
    User.changeset(attrs)
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, password_confirmation: false)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  def get_user_by_provider(provider, email) do
    query =
      from(u in User,
        join: i in assoc(u, :accounts_users_identities),
        where:
          i.provider == ^to_string(provider) and
            fragment("lower(?)", u.email) == ^String.downcase(email)
      )

    Repo.one(query)
  end

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def register_oauth_user(provider, user, token) do
    user_identity_changeset = UserIdentity.oauth_changeset(provider, user, token)

    if existing_user = get_user_by_email(user["email"]) do
      UserIdentities.create_user_identity(existing_user, user_identity_changeset)
    else
      user_identity_changeset
      |> User.oauth_changeset(user)
      |> Repo.insert()
    end
  end
end
