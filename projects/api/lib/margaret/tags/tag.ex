defmodule Margaret.Tags.Tag do
  @moduledoc """
  The Tag schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Stories, Publications}
  alias Stories.Story
  alias Publications.Publication

  @type t :: %Tag{}

  schema "tags" do
    field(:title, :string)

    many_to_many(:stories, Story, join_through: "story_tags")
    many_to_many(:publications, Publication, join_through: "publication_tags")

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    permitted_attrs = ~w(
      title
    )a

    required_attrs = ~w(
      title
    )a

    %Tag{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:title)
  end
end
