defmodule Margaret.StoryViews do
  @moduledoc """
  The Story Views context.
  """

  alias Margaret.{
    Repo,
    Accounts,
    StoryViews
  }

  alias Accounts.User
  alias StoryViews.StoryView

  @doc """
  Inserts a story view.

  ## Examples

      iex> view_story(story: %Story{})
      {:ok, %StoryView{}}

      iex> view_story(story: %Story{}, viewer: %User{})
      {:ok, %StoryView{}}

  """
  @spec view_story(Keyword.t()) :: {:ok, StoryView.t()} | {:error, Ecto.Changeset.t()}
  def view_story(clauses) do
    story_id = get_story_id_from_clauses(clauses)
    viewer_id = get_viewer_id_from_clauses(clauses)

    attrs = %{story_id: story_id, viewer_id: viewer_id}
    insert_story_view(attrs)
  end

  defp get_story_id_from_clauses(clauses) do
    clauses
    |> Keyword.fetch!(:story)
    |> Map.fetch!(:id)
  end

  defp get_viewer_id_from_clauses(clauses) do
    clauses
    |> Keyword.get(:viewer)
    |> case do
      %User{id: user_id} -> user_id
      nil -> nil
    end
  end

  defp insert_story_view(attrs) do
    attrs
    |> StoryView.changeset()
    |> Repo.insert()
  end
end
