defmodule Margaret.Comments.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stories, Stars}
  alias Accounts.User
  alias Stories.Story
  alias Stars.Star

  @type t :: %Comment{}

  @permitted_attrs [
    :author_id,
    :content,
    :story_id,
    :parent_id,
  ]

  @required_attrs [
    :author_id,
    :content,
    :story_id,
  ]

  schema "comments" do
    field :content, :map
    belongs_to :author, User
    has_many :stars, Star

    belongs_to :parent, Comment
    belongs_to :story, Story

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:parent_id)
  end

  @doc false
  def update_changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:content])
  end
end
