{:ok, _apps} = Application.ensure_all_started(:ex_machina)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Margaret.Repo, :manual)

Absinthe.Test.prime(MargaretWeb.Schema)
