# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :aria,
  ecto_repos: [Aria.Repo]

# Configures the endpoint
config :aria, AriaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AriaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Aria.PubSub,
  live_view: [signing_salt: "tmkheHUB"],
  watchers: [
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]},
    sass: {DartSass, :install_and_run, [:default, ~w(--watch)]}
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :aria, Aria.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.0.24",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=../priv/static/assets/app.tailwind.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :dart_sass,
  version: "1.49.11",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.tailwind.css),
    cd: Path.expand("../assets", __DIR__)
  ]

config :aria, :strategies,
  github: [
    client_id: "bf1e7eedd47b9391f986",
    client_secret: "7ac343b0a5cd0ca86e79696c4dc60421242ab321",
    redirect_uri: "http://localhost:4000/oauth/callback/github",
    http_adapter: Assent.HTTPAdapter.Mint,
    strategy: Assent.Strategy.Github
  ],
  google: [
    client_id: "482550277576-vqosie6ka4tgnankkqpfl2jv8p31ul7e.apps.googleusercontent.com",
    client_secret: "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",
    redirect_uri: "http://localhost:4000/oauth/callback/google",
    http_adapter: Assent.HTTPAdapter.Mint,
    strategy: Assent.Strategy.Google
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
