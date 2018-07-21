defmodule Margaret.UserSettings.Notifications do
  @moduledoc """
  The Notifications schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @type t :: %Notifications{}

  @primary_key false
  embedded_schema do
    field(:new_stories, :boolean, default: true)
    field(:new_followers, :boolean, default: true)

    field(:starred_stories, :boolean, default: true)
    field(:starred_comments, :boolean, default: false)
  end

  @doc """
  Builds a changeset for inserting or updating a notifications struct.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(notifications, attrs) do
    permitted_attrs = ~w(
      new_stories
      new_followers
      starred_stories
      starred_comments
    )a

    notifications
    |> cast(attrs, permitted_attrs)
  end
end
