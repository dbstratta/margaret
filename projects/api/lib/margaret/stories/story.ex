defmodule Margaret.Stories.Story do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Story
  alias Margaret.Accounts.User
  alias Margaret.Stars.{Star, StoryStar}

  @typedoc "The Story type"
  @type t :: %Story{}

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    many_to_many :stars, Star, join_through: StoryStar

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:title, :body, :user_id, :summary])
    |> validate_required([:title, :body])
    |> foreign_key_constraint(:user_id)
  end
end
