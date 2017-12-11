defmodule Margaret.Publications.Publication do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Publication
  alias Margaret.Accounts.User

  @typedoc "The Publication type"
  @type t :: %Publication{}

  schema "publications" do
    field :name, :string
    belongs_to :owner, User
    many_to_many :editors, User
    has_many :followers, User

    timestamps()
  end

  @doc false
  def changeset(%Publication{} = publication, attrs) do
    publication
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name, :owner_id])
    |> validate_length(:name, min: 2, max: 64)
    |> foreign_key_constraint(:owner_id)
  end
end
