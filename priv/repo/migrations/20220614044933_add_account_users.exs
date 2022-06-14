defmodule Aria.Repo.Migrations.AddAccountUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:accounts_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :is_confirmed, :boolean, default: false
      add :confirmed_at, :utc_datetime
      timestamps()
    end

    create unique_index(:accounts_users, [:email])

    create table(:accounts_users_tokens, primary_key: false) do
      add :user_id, references(:accounts_users, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :otp, :string
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:accounts_users_tokens, [:user_id])
    create unique_index(:accounts_users_tokens, [:context, :token])
  end
end
