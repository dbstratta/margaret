defmodule Margaret.UserSettings.Settings do
  @moduledoc """
  The User Settings schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    UserSettings.Notifications
  }

  @type t :: %Settings{}

  @primary_key false
  embedded_schema do
    embeds_one(:notifications, Notifications, on_replace: :update)
  end

  @doc """
  Builds a changeset for inserting a user settings struct.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(settings, attrs) do
    permitted_attrs = ~w()a

    required_attrs = ~w()a

    settings
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> cast_embed(:notifications, required: true)
  end

  @doc """
  Builds a changeset for updating a user settings struct.
  """
  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(settings, attrs) do
    permitted_attrs = ~w(
    )a

    settings
    |> cast(attrs, permitted_attrs)
    |> cast_embed(:notifications)
  end
end
