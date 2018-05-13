defmodule Margaret.Helpers do
  @moduledoc false

  import Ecto.Changeset

  @type ok_tuple :: {:ok, any()}
  @type error_tuple :: {:error, any()}

  @doc """
  Returns an ok tuple.

  ## Examples

      iex> ok(3)
      {:ok, 3}

      iex> ok(nil)
      {:ok, nil}

  """
  @spec ok(any()) :: ok_tuple()
  def ok(thing), do: {:ok, thing}

  @doc """
  Returns an ok tuple.

  ## Examples

      iex> error(changeset)
      {:error, changeset}

      iex> error(nil)
      {:error, nil}

  """
  @spec error(any) :: error_tuple()
  def error(reason), do: {:error, reason}

  @doc """
  """
  @spec maybe_put_assoc(Ecto.Changeset.t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def maybe_put_assoc(%Ecto.Changeset{} = changeset, attrs, opts) do
    key = Keyword.fetch!(opts, :key)

    case Map.get(attrs, key) do
      value when not is_nil(value) -> put_assoc(changeset, key, value)
      nil -> changeset
    end
  end

  @doc """
  """
  @spec maybe_put_tags_assoc(Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def maybe_put_tags_assoc(%Ecto.Changeset{} = changeset, attrs),
    do: maybe_put_assoc(changeset, attrs, key: :tags)

  @doc """
  Converts the keys of a map from strings to atoms.
  Optionally converts specified values too.

  Useful when deserializing data from external services.

  ## Examples

      iex> atomify_map(%{"hello" => "world"})
      %{hello: "world"}

      iex> atomify_map(%{"hello" => "world"}, values: [:hello])
      %{hello: :world}

  """
  def atomify_map(map, opts \\ []) when is_map(map) do
    map = for {key, value} <- map, into: %{}, do: {String.to_atom(key), value}

    values = Keyword.get(opts, :values, [])

    Enum.reduce(values, map, fn key, map -> Map.update!(map, key, &String.to_atom(&1)) end)
  end

  @doc """
  Changeset validator that validates the data exported by DraftJS.

  TODO: Refactor this function into a function that takes the
  changeset as first argument.

  ## Examples

      iex> validate_draftjs_data(:content, data)
      []

      iex> validate_draftjs_data(:content, invalid_data)
      [content: "invalid data"]

      iex> validate_change(changeset, :content, &validate_draftjs_data/2)
      %Ecto.Changeset{}

  """
  @spec validate_draftjs_data(atom(), map()) :: [any()]
  def validate_draftjs_data(_, data) when is_map(data) do
    []
  end

  def validate_draftjs_data(field, _data), do: [{field, "invalid data"}]

  @doc """
  """
  defmacro lower(a) do
    quote do
      fragment("lower(?)", unquote(a))
    end
  end

  @doc """
  """
  defmacro upper(a) do
    quote do
      fragment("upper(?)", unquote(a))
    end
  end
end
