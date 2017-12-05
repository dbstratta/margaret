defmodule Margaret.Stars.StoryStar do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: StoryStar
  alias Margaret.Stars.Star
  alias Margaret.Stories.Story

  @typedoc "The StoryStar type"
  @type t :: %StoryStar{}

  schema "story_stars" do
    belongs_to :story, Story
    belongs_to :star, Star

    timestamps()
  end

  @doc false
  def changeset(%StoryStar{} = story_star, attrs) do
    story_star
    |> cast(attrs, [:story_id, :star_id])
    |> validate_required([:story_id, :star_id])
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:star_id)
  end
end
