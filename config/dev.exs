use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :echo, Echo.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin"]]

# Watch static and templates for browser reloading.
config :echo, Echo.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :echo, Echo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "echo_dev",
  hostname: "localhost",
  pool_size: 10

config :echo, Echo.GCMWorker,
  api_key: "AAAAFvLnbyE:APA91bHCHZZazy9oJvUr-JJwaENNEHzZF1UNeZit32GRGURKPyPaAm1rgvmXT29DtuleWfNEqoSnuaLej-uwoNlvb2Fe-cGAPCywYXFNDIT3jlT2MHY3EOMJdVBT6IE2ycDWfj5gA9oZMuhQrvcSTEtz-GrdPndBnQ"
