use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :echo, Echo.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :echo, Echo.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "echo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :comeonin, :bcrypt_log_rounds, 4

config :echo, Echo.Notify,
  api_key: "test-api-key"