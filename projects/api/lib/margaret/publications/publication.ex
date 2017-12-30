defmodule Margaret.Publications.Publication do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Publications}
  alias Accounts.{User, Follow}
  alias Publications.PublicationMembership

  @type t :: %Publication{}

  @permitted_attrs [
    :name,
    :display_name,
  ]

  @required_attrs [
    :name,
    :display_name,
  ]

  schema "publications" do
    field :name, :string
    field :display_name, :string

    many_to_many :members, User, join_through: PublicationMembership

    many_to_many :followers, User,
      join_through: Follow,
      join_keys: [publication_id: :id, follower_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%Publication{} = publication, attrs) do
    publication
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
  end
end
