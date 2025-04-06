defmodule Harezm.Admin do
  use Ash.Api,
    extensions: [AshAuthentication]

  resources do
    resource(Harezm.Resources.User)
    resource(Harezm.Resources.Token)
  end
end
