defmodule Margaret.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Accounts.{User, SocialLogin}

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_username(username), do: Repo.get_by(User, username: username)

  def get_user_by_social_login!(provider, uid) do
    Repo.get_by!(SocialLogin, [provider: provider, uid: uid])
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
