defmodule Aria.Repo.Migrations.CreateUserIdentitisTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:accounts_users_identities, primary_key: false) do
      add :user_id, references(:accounts_users, type: :uuid, on_delete: :delete_all), null: false
      add :provider, :string, null: false
      add :provider_token, :string, null: false
      add :provider_login, :string, null: false
      add :provider_email, :string, null: false
      add :provider_id, :string, null: false
      add :provider_meta, :map, default: "{}", null: false

      timestamps()
    end

    create index(:accounts_users_identities, [:user_id])
    create index(:accounts_users_identities, [:provider])
    create unique_index(:accounts_users_identities, [:user_id, :provider])
  end
end
