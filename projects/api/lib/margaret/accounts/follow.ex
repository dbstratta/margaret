defmodule Margaret.Accounts.Follow do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @type t :: %Follow{}

  @permitted_attrs [
    :follower_id,
    :user_id,
    :publication_id
  ]

  @required_attrs [
    :follower_id
  ]

  schema "follows" do
    belongs_to(:follower, User)
    belongs_to(:user, User)
    belongs_to(:publication, Publication)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %Follow{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:follower_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:publication_id)
    |> unique_constraint(:follower, name: :follows_follower_id_user_id_index)
    |> unique_constraint(:follower, name: :follows_follower_id_publication_id_index)
    |> check_constraint(:follower, name: :only_one_not_null_followable)
    |> check_constraint(:follower, name: :cannot_follow_follower)
  end
end
