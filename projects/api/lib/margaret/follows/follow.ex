defmodule Margaret.Follows.Follow do
  @moduledoc """
  The Follow schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Publications.Publication
  }

  @type t :: %Follow{}

  schema "follows" do
    belongs_to(:follower, User)

    # Followables.
    belongs_to(:user, User)
    belongs_to(:publication, Publication)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a follow.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    permitted_attrs = ~w(
      follower_id
      user_id
      publication_id
    )a

    required_attrs = ~w(
      follower_id
    )a

    %Follow{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:follower)
    |> assoc_constraint(:user)
    |> assoc_constraint(:publication)
    |> unique_constraint(:follower, name: :follows_follower_id_user_id_index)
    |> unique_constraint(:follower, name: :follows_follower_id_publication_id_index)
    |> check_constraint(:follower, name: :only_one_not_null_followable)
    |> check_constraint(:follower, name: :cannot_follow_follower)
  end

  @doc """
  Preloads the follower of a follow.
  """
  @spec preload_follower(t()) :: t()
  def preload_follower(%Follow{} = follow), do: Repo.preload(follow, :follower)

  @doc """
  Preloads the user of a follow.
  """
  @spec preload_user(t()) :: t()
  def preload_user(%Follow{} = follow), do: Repo.preload(follow, :user)

  @doc """
  Preloads the publication of a follow.
  """
  @spec preload_publication(t()) :: t()
  def preload_publication(%Follow{} = follow), do: Repo.preload(follow, :publication)
end
