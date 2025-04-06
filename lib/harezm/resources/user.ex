defmodule Harezm.Resources.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key(:id)
    attribute(:email, :ci_string, allow_nil?: false)
    attribute(:username, :ci_string, allow_nil?: false)

    attribute(:role, :atom,
      allow_nil?: false,
      default: :user,
      constraints: [one_of: [:admin, :user]]
    )

    attribute(:hashed_password, :string, sensitive?: true, allow_nil?: false)
    timestamps()
  end

  authentication do
    api(Harezm.Admin)

    strategies do
      password :password do
        identity_field(:email)
        hashed_password_field(:hashed_password)
        sign_in_tokens_enabled?(true)
        register_enabled?(true)
        resettable?(true)
      end
    end

    tokens do
      enabled?(true)
      token_resource(Harezm.Resources.Token)
      signing_secret(fn _, _ -> Application.fetch_env(:harezm, :token_signing_secret) end)
    end
  end

  postgres do
    table("users")
    repo(Harezm.Repo)
  end

  identities do
    identity(:unique_email, [:email])
    identity(:unique_username, [:username])
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :admin_list do
      prepare(build(load: [:role]))
      filter(expr(role == :admin))
    end
  end

  policies do
    bypass :create do
      authorize_if(always())
    end

    policy action_type(:read) do
      authorize_if(expr(actor.id == subject.id))
      authorize_if(actor_attribute_equals(:role, :admin))
    end

    policy action_type(:update) do
      authorize_if(expr(actor.id == subject.id))
      authorize_if(actor_attribute_equals(:role, :admin))
    end

    policy action_type(:destroy) do
      authorize_if(actor_attribute_equals(:role, :admin))
    end
  end
end
