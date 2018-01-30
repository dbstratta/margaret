defmodule Margaret.Stories.StoryView do
  @moduledoc """
  The StoryView schema and changesets.

  A story view represents the act of a user viewing a story.
  It is useful to store this events because we can later
  analyse this data and calculate popular stories,
  for example.
  """

  use Ecto.Schema
  import Ecto.Changeset

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
end
