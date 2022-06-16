defmodule Aria.Repo.Migrations.AddNameUsernameAvatarUrlToUserTable do
  use Ecto.Migration

  def change do
    alter table(:accounts_users) do
      add :username, :string
      add :avatar_url, :string
    end
  end
end
