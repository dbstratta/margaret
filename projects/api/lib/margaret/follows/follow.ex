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
  Filters the follows by follower.
  """
  @spec by_follower(Ecto.Queryable.t(), User.t()) :: Ecto.Query.t()
  def by_follower(query \\ Follow, %User{id: follower_id}),
    do: where(query, [..., f], f.follower_id == ^follower_id)

  @doc """
  Filters the follows by followed user.
  """
  @spec by_user(Ecto.Queryable.t(), User.t()) :: Ecto.Query.t()
  def by_user(query \\ Follow, %User{id: user_id}),
    do: where(query, [..., f], f.user_id == ^user_id)

  @doc """
  Filters the follows by followed publication.
  """
  @spec by_publication(Ecto.Queryable.t(), Publication.t()) :: Ecto.Query.t()
  def by_publication(query \\ Follow, %Publication{id: publication_id}),
    do: where(query, [..., f], f.publication_id == ^publication_id)

  @doc """
  Filters the follows by followee.
  """
  @spec by_followee(Ecto.Queryable.t(), User.t() | Publication.t()) :: Ecto.Queryable.t()
  def by_followee(query \\ Follow, followee)
  def by_followee(query, %User{} = user), do: by_user(query, user)
  def by_followee(query, %Publication{} = publication), do: by_publication(query, publication)

  def followees(query \\ Follow, %User{} = user, _opts \\ []) do
    query
    |> Follow.by_follower(user)
    |> join(:left, [f], u in assoc(f, :user))
    |> User.active()
    |> join(:left, [f], p in assoc(f, :publication))
    |> select([f, u, p], {[u, p], %{followed_at: f.inserted_at}})
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
