defmodule Margaret.Publications.Publication do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Publication
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.PublicationMembership

  @typedoc "The Publication type"
  @type t :: %Publication{}

  schema "publications" do
    field :name, :string
    field :display_name, :string

    many_to_many :members, User,
      join_through: PublicationMemberhip,
      unique: true

    timestamps()
  end

  @doc false
  def changeset(%Publication{} = publication, attrs) do
    publication
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 64)
  end
end
