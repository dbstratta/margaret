defmodule Margaret.Comments.Comment do
  @moduledoc """
  The Comment schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Stories.Story,
    Stars.Star
  }

  @type t :: %Comment{}

  schema "comments" do
    field(:content, :map)

    belongs_to(:author, User)

    # Comments can be starred.
    has_many(:stars, Star)

    # Commentables.
    belongs_to(:parent, Comment)
    belongs_to(:story, Story)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a comment.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      author_id
      content
      story_id
      parent_id
    )a

    required_attrs = ~w(
      author_id
      content
      story_id
    )a

    %Comment{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:author)
    |> assoc_constraint(:story)
    |> assoc_constraint(:parent)
  end

  @doc """
  Builds a changeset for updating a comment.
  """
  def update_changeset(%Comment{} = comment, attrs) do
    permitted_attrs = ~w(
      content
    )a

    comment
    |> cast(attrs, permitted_attrs)
  end

  @doc """
  """
  @spec by_story(Ecto.Query.t(), Story.t()) :: Ecto.Query.t()
  def by_story(query \\ Comment, %Story{id: story_id}),
    do: where(query, [..., c], c.story_id == ^story_id)

  @doc """
  """
  @spec by_parent(Ecto.Query.t(), t()) :: Ecto.Query.t()
  def by_parent(query \\ Comment, %Comment{id: parent_id}),
    do: where(query, [..., c], c.parent_id == ^parent_id)

  @doc """
  Preloads the author of a comment.
  """
  @spec preload_author(t) :: t
  def preload_author(%Comment{} = comment), do: Repo.preload(comment, :author)

  @doc """
  Preloads the story of a comment.
  """
  @spec preload_story(t) :: t
  def preload_story(%Comment{} = comment), do: Repo.preload(comment, :story)

  @doc """
  Preloads the parent comment of a comment.
  """
  @spec preload_parent(t) :: t
  def preload_parent(%Comment{} = comment), do: Repo.preload(comment, :parent)
end
