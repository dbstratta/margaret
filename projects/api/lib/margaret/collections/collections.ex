defmodule Margaret.Collections do
  @moduledoc """
  The Collections context.
  """

  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Stories, Publications, Collections}
  alias Accounts.User
  alias Stories.Story
  alias Collections.{Collection, CollectionStory}

  @doc """
  Gets a collection.
  """
  @spec get_collection(String.t() | non_neg_integer) :: Collection.t() | nil
  def get_collection(id), do: Repo.get(Collection, id)
end
