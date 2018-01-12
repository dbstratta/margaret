defmodule MargaretWeb.Resolvers.Followable do
  @moduledoc """
  The Followable GraphQL resolvers.
  """

  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @doc """
  Resolves the follow of a followable.
  """
  def resolve_follow(
    %{followable_id: %{type: :user, id: user_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    user_id
    |> Accounts.get_user()
    |> do_resolve_follow(viewer_id)
  end

  def resolve_follow(
    %{followable_id: %{type: :publication, id: publication_id}},
    %{context: %{viewer: %{id: viewer_id}}}
  ) do
    publication_id
    |> Publications.get_publication()
    |> do_resolve_follow(viewer_id)
  end

  defp do_resolve_follow(%User{id: user_id} = followee, viewer_id) do
    case Accounts.insert_follow(%{follower_id: viewer_id, user_id: user_id}) do
      {:ok, _} ->
        {:ok, %{followable: followee}}
      {:error, %{errors: [follower: {"has already been taken", []}]}} ->
        {:ok, %{followable: followee}}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  defp do_resolve_follow(%Publication{id: publication_id} = followee, viewer_id) do
    case Accounts.insert_follow(%{follower_id: viewer_id, publication_id: publication_id}) do
      {:ok, _} ->
        {:ok, %{followable: followee}}
      {:error, %{errors: [follower: {"has already been taken", []}]}} ->
        {:ok, %{followable: followee}}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  defp do_resolve_follow(nil, _), do: {:error, "Followable doesn't exist."}

  @doc """
  Resolves the unfollow of a followable.
  """
  def resolve_unfollow(
    %{followable_id: %{type: :user, id: user_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    user_id
    |> Accounts.get_user()
    |> do_resolve_unfollow(viewer_id)
  end

  def resolve_unfollow(
    %{followable_id: %{type: :publication, id: publication_id}},
    %{context: %{viewer: %{id: viewer_id}}}
  ) do
    publication_id
    |> Publications.get_publication()
    |> do_resolve_unfollow(viewer_id)
  end

  defp do_resolve_unfollow(%User{id: user_id} = followable, viewer_id) do
    Accounts.delete_follow(follower_id: viewer_id, user_id: user_id)
    {:ok, %{followable: followable}}
  end

  defp do_resolve_unfollow(%Publication{id: publication_id} = followable, viewer_id) do
    Accounts.delete_follow(follower_id: viewer_id, publication_id: publication_id)
    {:ok, %{followable: followable}}
  end

  defp do_resolve_unfollow(nil, _), do: {:error, "Followable doesn't exist."}
end
