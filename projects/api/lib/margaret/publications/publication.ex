defmodule Margaret.Publications.Publication do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts.User, Publications.PublicationMembership}

  schema "publications" do
    field :name, :string
    field :display_name, :string

    many_to_many :members, User,
      join_through: PublicationMembership,
      unique: true

    timestamps()
  end

  @doc false
  def changeset(%Publication{} = publication, attrs) do
    publication
    |> cast(attrs, [:name, :display_name])
    |> validate_required([:name, :display_name])
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
  end
end
