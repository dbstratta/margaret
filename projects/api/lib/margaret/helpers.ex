defmodule Margaret.Helpers do
  @moduledoc false

  import Ecto.Changeset

  @doc """
  """
  def maybe_put_assoc(%Ecto.Changeset{} = changeset, attrs, opts \\ []) do
    key = Keyword.get(opts, :key)

    do_maybe_put_assoc(changeset, attrs, key)
  end

  defp do_maybe_put_assoc(changeset, _attrs, nil), do: changeset

  defp do_maybe_put_assoc(changeset, attrs, key) do
    if Map.has_key?(attrs, key) do
      put_assoc(changeset, key, Map.get(attrs, key))
    else
      changeset
    end
  end

  @doc """
  """
  def maybe_put_tags_assoc(%Ecto.Changeset{} = changeset, attrs) do
    maybe_put_assoc(changeset, attrs, key: :tags)
  end

  @doc """
  TODO: Document this.
  """
  def atomify_map(map, opts \\ []) do
    map = for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}

    values = Keyword.get(opts, :values, [])

    Enum.reduce(values, map, fn key, map -> Map.update!(map, key, &String.to_atom(&1)) end)
  end
end
