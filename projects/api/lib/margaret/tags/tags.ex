defmodule Margaret.Tags do
  @moduledoc """
  The Tags context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Tags,
    Helpers
  }

  alias Tags.Tag

  @doc """
  Gets a tag by its id.

  ## Examples

      iex> get_tag(123)
      %Tag{}

      iex> get_tag(456)
      nil

  """
  @spec get_tag(String.t() | non_neg_integer) :: Tag.t() | nil
  def get_tag(id), do: Repo.get(Tag, id)

  @doc """
  Gets a tag by its id.

  Raises `Ecto.NoResultsError` if the tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_tag!(String.t() | non_neg_integer) :: Tag.t() | no_return
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Gets a tag by its title.

  ## Examples

      iex> get_tag_by_title("elixir")
      %Tag{}

      iex> get_tag_by_title("productivity")
      nil

  """
  @spec get_tag_by_title(String.t()) :: Tag.t() | nil
  def get_tag_by_title(title), do: Repo.get_by(Tag, title: title)

  @doc """
  Inserts a tag.
  """
  def insert_tag(attrs) do
    attrs
    |> Tag.changeset()
    |> Repo.insert()
  end

  def insert_and_get_all_tags_multi(multi, tag_titles, opts \\ []) do
    multi_key = Keyword.get(opts, :key, :tags)

    insert_and_get_all_tags_fn = fn _ ->
      tag_titles
      |> Tags.insert_and_get_all_tags()
      |> Helpers.ok()
    end

    Multi.run(multi, multi_key, insert_and_get_all_tags_fn)
  end

  @doc """
  Inserts all the tags that weren't persisted and
  gets all the tags from the `tags` list.

  ## Examples

      iex> insert_and_get_all_tags(["programming", "elixir"])
      [%Tag{title: "programming"}, %Tag{title: "elixir"}]

      iex> insert_and_get_all_tags([])
      []

  """
  @spec insert_and_get_all_tags([String.t()]) :: [%Tag{}]
  def insert_and_get_all_tags(tag_titles) when is_list(tag_titles) do
    insert_tags(tag_titles)

    tags(%{titles: tag_titles})
  end

  defp insert_tags(tag_titles) do
    tag_entries = tag_entries_from_tag_titles(tag_titles)

    Repo.insert_all(Tag, tag_entries, on_conflict: :nothing)
  end

  defp tag_entries_from_tag_titles(tag_titles) do
    now = NaiveDateTime.utc_now()

    tag_titles
    |> Stream.map(&String.trim/1)
    |> Stream.map(&%{title: &1})
    |> Stream.map(&Map.put(&1, :inserted_at, now))
    |> Enum.map(&Map.put(&1, :updated_at, now))
  end

  def tags(args \\ %{}) do
    args
    |> Tags.Queries.tags()
    |> Repo.all()
  end
end
