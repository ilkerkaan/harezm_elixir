defmodule Harezm.Repo do
  use Ecto.Repo,
    otp_app: :harezm,
    adapter: Ecto.Adapters.Postgres
end
