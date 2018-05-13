defmodule Margaret.Accounts.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{
    Accounts,
    Publications
  }

  alias Accounts.User
  alias Publications.Publication

  @doc """
  """
  @spec users(map()) :: Ecto.Query.t()
  def users(args \\ %{}) do
    query = User

    query
    |> maybe_filter_active_users(args)
    |> maybe_filter_by_publication(args)
  end

  defp maybe_filter_active_users(query, args) do
    if Map.get(args, :active_only, true) do
      from(u in query, where: is_nil(u.deactivated_at))
    else
      query
    end
  end

  defp maybe_filter_by_publication(query, args) do
    case Map.get(args, :publication) do
      %Publication{id: publication_id} ->
        from(
          u in query,
          join: pm in assoc(u, :publication_memberships),
          where: pm.publication_id == ^publication_id
        )
        |> maybe_filter_by_publication_role(args)

      nil ->
        query
    end
  end

  defp maybe_filter_by_publication_role(query, args) do
    case Map.get(args, :role) do
      role when not is_nil(role) -> from([..., pm] in query, where: pm.role == ^role)
      nil -> query
    end
  end
end
