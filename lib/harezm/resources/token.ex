defmodule Harezm.Resources.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api(Harezm.Admin)
  end

  postgres do
    table("tokens")
    repo(Harezm.Repo)
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end
end
