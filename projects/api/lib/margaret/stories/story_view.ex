defmodule Margaret.Stories.StoryView do
  @moduledoc """
  The StoryView schema and changesets.

  A story view represents the act of a user viewing a story.
  It is useful to store this events because we can later
  analyse this data and calculate popular stories,
  for example.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Accounts.User,
    Stories.Story
  }

  @type t :: %StoryView{}

  schema "story_views" do
    belongs_to(:story, Story)
    belongs_to(:viewer, User)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a story view.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      story_id
      viewer_id
    )a

    required_attrs = ~w(
      story_id
    )a

    %StoryView{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:story)
    |> assoc_constraint(:viewer)
  end

  @doc """
  Filters the views by story.
  """
  @spec by_story(Ecto.Query.t(), Story.t()) :: Ecto.Query.t()
  def by_story(query \\ StoryView, %Story{id: story_id}),
    do: where(query, [..., sv], sv.story_id == ^story_id)

  @doc """
  Filters the views by viewer.
  """
  @spec by_viewer(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_viewer(query \\ StoryView, %User{id: viewer_id}),
    do: where(query, [..., sv], sv.viewer_id == ^viewer_id)
end
