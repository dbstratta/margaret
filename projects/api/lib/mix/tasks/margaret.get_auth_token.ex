defmodule Mix.Tasks.Margaret.GetAuthToken do
  @moduledoc """
  Gets the authentication token of a user.
  """

  @shortdoc "Gets the authentication token of a user."

  use Mix.Task
  import Mix, only: [shell: 0]
  import Mix.Ecto, only: [ensure_started: 2]

  alias Margaret.{Repo, Accounts}
  alias Accounts.User

  @switches [
    id: :string,
    email: :string,
    username: :string,
  ]

  @doc false
  def run(args) do
    ensure_started(Repo, [])

    args
    |> parse_opts()
    |> do_run()
  end

  defp do_run(opts) do
    map =
      cond do
        Keyword.has_key?(opts, :id) -> %{id: Keyword.get(opts, :id)}
        Keyword.has_key?(opts, :email) -> %{email: Keyword.get(opts, :email)}
        Keyword.has_key?(opts, :username) -> %{username: Keyword.get(opts, :username)}
      end
    
    map
    |> get_user()
    |> get_token()
    |> print_token()
  end

  defp get_user(%{id: id}), do: Accounts.get_user!(id)
  defp get_user(%{email: email}), do: Accounts.get_user_by_email!(email)
  defp get_user(%{username: username}), do: Accounts.get_user_by_username!(username)

  defp get_token(%User{} = user) do
    {:ok, token, _} = MargaretWeb.Guardian.encode_and_sign(user)

    token
  end

  defp print_token(token), do: shell().info("Success!\nToken: #{token}")

  defp parse_opts(args) do
    {opts, _, _} = OptionParser.parse(args, switches: @switches)

    opts
  end
end