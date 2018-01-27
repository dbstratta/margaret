ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Margaret.Repo, :manual)

Absinthe.Test.prime(MargaretWeb.Schema)
