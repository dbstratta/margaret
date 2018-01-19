defmodule Margaret.Stars.Star do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stories, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment

  @type t :: %Star{}

  @permitted_attrs [
    :user_id,
    :story_id,
    :comment_id
  ]

  @required_attrs [
    :user_id
  ]

  schema "stars" do
    belongs_to(:user, User)

    belongs_to(:story, Story)
    belongs_to(:comment, Comment)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %Star{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:comment_id)
    |> unique_constraint(:user, name: :stars_user_id_story_id_index)
    |> unique_constraint(:user, name: :stars_user_id_comment_id_index)
    |> check_constraint(:user, name: :only_one_not_null_starrable)
  end
end
