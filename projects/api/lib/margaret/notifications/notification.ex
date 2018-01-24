defmodule Margaret.Notifications.Notification do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__
  alias Margaret.Accounts
  alias Accounts.User

  @type t :: %Notification{}

  @permitted_attrs [
    "actor_id",
    "action"
  ]

  @required_attrs [
    "action"
  ]

  defenum NotificationAction, :notification_action, [:added, :updated, :deleted]

  schema "notifications" do
    belongs_to(:actor, User)
    field(:action, NotificationAction)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %Notification{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> validate_action()
  end

  defp validate_action(changeset) do
    changeset
  end
end
