defmodule Margaret.Stories.StoryPublicationSchedule do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @type t :: %StoryPublicationSchedule{}

  @permitted_attrs [
    :story_id,
    :publish_at,
  ]

  @required_attrs [
    :story_id,
    :publish_at,
  ]
  
  @primary_key {:story_id, :id, autogenerate: false}
  schema "story_publication_schedules" do
    field :publish_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(%StoryPublicationSchedule{} = schedule, attrs) do
    schedule
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:story_id)
    |> unique_constraint(:story_id)
  end
end
