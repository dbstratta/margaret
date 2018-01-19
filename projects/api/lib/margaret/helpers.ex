defmodule Margaret.Helpers do
  import Ecto.Changeset

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

  def maybe_put_tags_assoc(%Ecto.Changeset{} = changeset, attrs) do
    maybe_put_assoc(changeset, attrs, key: :tags)
  end
end
