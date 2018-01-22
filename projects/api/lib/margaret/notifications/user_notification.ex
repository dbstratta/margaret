defmodule Margaret.Notifications.UserNotification do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.Accounts
  alias Accounts.User

  @type t :: %UserNotification{}

  @permitted_attrs [
    "user_id"
  ]

  @required_attrs [
    "user_id"
  ]

  schema "user_notifications" do
    belongs_to(:user, User)
    field(:read_at, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %UserNotification{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:user_id)
  end
end
