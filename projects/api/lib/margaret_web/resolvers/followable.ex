defmodule MargaretWeb.Resolvers.Followable do
  @moduledoc """
  The Followable GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias Margaret.{Accounts, Publications}
  alias MargaretWeb.Helpers

  @doc """
  Resolves the follow of a followable.
  """
  def resolve_follow(
    %{followable_id: %{type: :user, id: user_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    case Accounts.insert_follow(%{follower_id: viewer_id, user_id: user_id}) do
      {:ok, _} -> {:ok, %{followable: Accounts.get_user(user_id)}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def resolve_follow(
    %{followable_id: %{type: :publication, id: publication_id}},
    %{context: %{viewer: %{id: viewer_id}}}
  ) do
    case Accounts.insert_follow(%{follower_id: viewer_id, publication_id: publication_id}) do
      {:ok, _} -> {:ok, %{followable: Publications.get_publication(publication_id)}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def resolve_follow(_, _), do: Helpers.GraphQLErrors.unauthorized()

  @doc """
  Resolves the unfollow of a followable.
  """
  def resolve_unfollow(
    %{followable_id: %{type: :user, id: user_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    case Accounts.delete_follow(%{follower_id: viewer_id, user_id: user_id}) do
      {:ok, _} -> {:ok, %{followable: Accounts.get_user(user_id)}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  def resolve_unfollow(
    %{followable_id: %{type: :publication, id: publication_id}},
    %{context: %{viewer: %{id: viewer_id}}}
  ) do
    case Accounts.delete_follow(%{follower_id: viewer_id, publication_id: publication_id}) do
      {:ok, _} -> {:ok, %{followable: Publications.get_publication(publication_id)}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      {:error, reason} -> {:error, reason}
    end
  end

  def resolve_unfollow(_, _), do: Helpers.GraphQLErrors.unauthorized()
end
