defmodule Aria.Accounts.UserIdentities do
  @moduledoc """
  The context module of the table accounts_users_identity
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Aria.Accounts.{User, UserIdentity}
  alias Aria.Repo

  def create_user_identity(%User{} = user, user_identity_changeset) do
    {:ok, _} =
      user_identity_changeset
      |> put_change(:user_id, user.id)
      |> Repo.insert()

    {:ok, Repo.preload(user, :accounts_users_identities, force: true)}
  end

  def update_oauth_token(provider, %User{} = user, new_token) do
    user_identity = get_user_identity(user.id, provider)

    {:ok, _} =
      user_identity
      |> change()
      |> put_change(:provider_token, new_token["access_token"])
      |> Repo.update()

    {:ok, Repo.preload(user, :accounts_users_identities, force: true)}
  end

  defp get_user_identity(user_id, provider) do
    from(
      i in UserIdentity,
      where: i.user_id == ^user_id and i.provider == ^provider
    )
    |> Repo.one!()
  end
end
