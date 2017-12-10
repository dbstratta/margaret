defmodule Margaret.Stars.Star do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Star
  alias Margaret.{Accounts, Stories, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment

  @typedoc "The Star type"
  @type t :: %Star{}

  schema "stars" do
    belongs_to :user, User

    belongs_to :story, Story
    belongs_to :comment, Comment

    timestamps()
  end

  @doc false
  def changeset(%Star{} = star, attrs) do
    star
    |> cast(attrs, [:user_id, :story_id, :comment_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:comment_id)
  end
end
