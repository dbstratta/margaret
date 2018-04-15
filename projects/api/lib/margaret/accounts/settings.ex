defmodule Margaret.Accounts.Settings do
  @moduledoc """
  The Settings schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  @type t :: %Settings{}

  @primary_key false
  embedded_schema do
    embeds_one(:notifications, Settings.Notifications)
  end

  @doc """
  Builds a changeset for inserting a user settings struct.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(settings, attrs) do
    permitted_attrs = ~w(
    )a

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

defmodule Margaret.Accounts.Settings.Notifications do
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
  end

  @doc """
  Builds a changeset for inserting or updating a notifications struct.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(notifications, attrs) do
    permitted_attrs = ~w(
      new_stories
    )a

    notifications
    |> cast(attrs, permitted_attrs)
  end
end
