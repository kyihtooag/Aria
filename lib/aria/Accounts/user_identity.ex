defmodule Aria.Accounts.UserIdentity do
  @moduledoc """
  Schema representing accounts_users_identities.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Aria.Accounts.{User, UserIdentity}

  @derive {Inspect, except: [:provider_token, :provider_meta]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users_identities" do
    field :provider, :string
    field :provider_token, :string
    field :provider_email, :string
    field :provider_name, :string, virtual: true
    field :provider_id, :string

    belongs_to :user, User

    timestamps()
  end

  def oauth_changeset(provider, user, token) do
    params = %{
      "provider" => provider,
      "provider_token" => token["access_token"],
      "provider_email" => user["email"],
      "provider_name" => user["name"],
      "provider_id" => get_provider_id(user["sub"])
    }

    %UserIdentity{}
    |> cast(params, [:provider, :provider_token, :provider_email, :provider_name, :provider_id])
    |> validate_required([
      :provider,
      :provider_token,
      :provider_email,
      :provider_name,
      :provider_id
    ])
  end

  defp get_provider_id(provider_id) when is_integer(provider_id),
    do: Integer.to_string(provider_id)

  defp get_provider_id(provider_id), do: provider_id
end
