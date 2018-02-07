defmodule Margaret.Follows.Follow do
  @moduledoc """
  The Follow schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

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
  Filters the follows by follower.
  """
  @spec by_follower(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_follower(query \\ Follow, %User{id: follower_id}),
    do: where(query, [..., f], f.follower_id == ^follower_id)

  @doc """
  Filters the follows by followed user.
  """
  @spec by_user(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_user(query \\ Follow, %User{id: user_id}),
    do: where(query, [..., f], f.user_id == ^user_id)

  @doc """
  Filters the follows by followed publication.
  """
  @spec by_publication(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_publication(query \\ Follow, %Publication{id: publication_id}),
    do: where(query, [..., f], f.publication_id == ^publication_id)

  @doc """
  Preloads the follower of a follow.
  """
  @spec preload_follower(t) :: t
  def preload_follower(%Follow{} = follow), do: Repo.preload(follow, :follower)
end
