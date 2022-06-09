defmodule Aria.Repo do
  use Ecto.Repo,
    otp_app: :aria,
    adapter: Ecto.Adapters.Postgres
end
