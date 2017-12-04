defmodule Margaret.Publications.Publication do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Publication

  @typedoc "The Publication type"
  @type t :: %Publication{}

  schema "publications" do
    field :name, :string

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
