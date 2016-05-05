ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Echo.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Echo.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Echo.Repo)

