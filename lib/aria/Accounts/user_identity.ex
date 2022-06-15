defmodule Aria.Accounts.UserIdentity do
  @moduledoc """
  Schema representing accounts_users_identities.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Aria.Accounts.User

  @derive {Inspect, except: [:provider_token, :provider_meta]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users_identities" do
    field :provider, :string
    field :provider_token, :string
    field :provider_email, :string
    field :provider_login, :string
    field :provider_name, :string, virtual: true
    field :provider_id, :string
    field :provider_meta, :map

    belongs_to :user, User

    timestamps()
  end

  def oauth_changeset(identity, attrs) do
    identity
    |> cast(attrs, [
      :provider_token,
      :provider_email,
      :provider_login,
      :provider_name,
      :provider_id
    ])
    |> validate_required([:provider_token, :provider_email, :provider_name, :provider_id])
    |> validate_length(:provider_meta, max: 10_000)
  end
end
