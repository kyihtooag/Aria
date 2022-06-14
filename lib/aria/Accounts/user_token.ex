defmodule Aria.Accounts.UserToken do
  @moduledoc """
  Schema representing accounts_users_tokens.
  """

  use Ecto.Schema
  alias Aria.Accounts.User

  @primary_key false
  schema "accounts_users_tokens" do
    field :token, :binary
    field :otp, :string
    field :context, :string
    field :sent_to, :string
    belongs_to :user, User, type: Ecto.UUID

    timestamps(updated_at: false)
  end
end
