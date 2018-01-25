defmodule Margaret.Stories.StoryView do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stories}
  alias Accounts.User
  alias Stories.Story

  @type t :: %StoryView{}

  @permitted_attrs [
    :story_id,
    :viewer_id
  ]

  @required_attrs [
    :story_id
  ]

  schema "story_views" do
    belongs_to(:story, Story)
    belongs_to(:viewer, User)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %StoryView{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:viewer_id)
  end
end
