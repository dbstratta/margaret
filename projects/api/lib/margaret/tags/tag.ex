defmodule Margaret.Tags.Tag do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.Stories.Story

  @type t :: %Tag{}

  schema "tags" do
    field :title, :string
    many_to_many :stories, Story, join_through: "story_tags"

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> unique_constraint(:title)
  end
end