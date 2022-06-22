defmodule Aria.Repo.Migrations.CreateGenres do
  use Ecto.Migration

  def change do
    create table(:media_genres, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :text, null: false
      add :slug, :text, null: false
    end

    create unique_index(:media_genres, [:title])
    create unique_index(:media_genres, [:slug])
  end
end
