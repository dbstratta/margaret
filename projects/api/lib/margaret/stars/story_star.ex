defmodule Margaret.Stars.StoryStar do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: StoryStar
  alias Margaret.Accounts.User
  alias Margaret.Stories.Story

  @typedoc "The StoryStar type"
  @type t :: %StoryStar{}

  schema "story_stars" do
    belongs_to :story, Story
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%StoryStar{} = story_star, attrs) do
    story_star
    |> cast(attrs, [:story_id, :user_id])
    |> validate_required([:story_id, :user_id])
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :story_star_user_id_story_id_index)
  end
end
