defmodule Margaret.Publications.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @doc """
  """
  @spec publications(map()) :: Ecto.Query.t()
  def publications(args \\ %{})

  def publications(%{member: %User{id: user_id}} = args) do
    role = Map.get(args, :role, :all)

    role_clause =
      case role do
        :all -> true
        role -> dynamic([_p, pm], pm.role == ^role)
      end

    from(
      p in Publication,
      join: pm in assoc(p, :publication_memberships),
      where: pm.member_id == ^user_id,
      where: ^role_clause,
      select: {p, %{role: pm.role, member_since: pm.inserted_at}}
    )
  end

  def publications(_args) do
    from(p in Publication)
  end
end
