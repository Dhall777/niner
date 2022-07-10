defmodule Niner.Repo do
  use Ecto.Repo,
    otp_app: :niner,
    adapter: Ecto.Adapters.Postgres
end
