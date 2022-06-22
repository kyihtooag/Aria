defmodule Aria.Repo.Migrations.CreateSong do
  use Ecto.Migration

  def change do
    create table(:media_songs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :album_artist, :string
      add :artist, :string, null: false
      add :duration, :integer, default: 0, null: false
      add :status, :integer, null: false, default: 1
      add :played_at, :utc_datetime
      add :paused_at, :utc_datetime
      add :title, :string, null: false
      add :attribution, :string
      add :mp3_url, :string, null: false
      add :mp3_filename, :string, null: false
      add :mp3_filesize, :integer, null: false, default: 0
      add :mp3_filepath, :string, null: false
      add :date_recorded, :naive_datetime
      add :date_released, :naive_datetime
      add :user_id, references(:accounts_users, type: :uuid, on_delete: :nothing)
      add :genre_id, references(:media_genres, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:media_songs, [:user_id, :title, :artist])
    create index(:media_songs, [:user_id])
    create index(:media_songs, [:genre_id])
    create index(:media_songs, [:status])
  end
end
