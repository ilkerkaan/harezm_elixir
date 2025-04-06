# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :harezm,
  ecto_repos: [Harezm.Repo],
  ash_apis: [Harezm.Admin],
  token_signing_secret: System.get_env("TOKEN_SIGNING_SECRET", "your-secret-key-base")

# Configures the endpoint
config :harezm, HarezmWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: HarezmWeb.ErrorHTML, json: HarezmWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Harezm.PubSub,
  live_view: [signing_salt: "Hs+Hs+Hs"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  harezm: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  harezm: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Ash
config :ash, :use_all_identities_in_manage_relationship?, false

config :ash_authentication,
  user_identity_field: :email,
  password_reset: [
    sender: {"Harezm", "noreply@harezm.com"},
    base_url: "http://localhost:4000/auth/password-reset"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
