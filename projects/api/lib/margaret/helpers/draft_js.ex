defmodule Margaret.Helpers.DraftJS do
  @moduledoc """
  Helper functions for dealing with DraftJS data validation.
  """

  @invalid_draftjs_data_message "invalid format"

  @doc """
  Changeset validator that validates the data exported by DraftJS.

  ## Examples

      iex> validate_draftjs_data(%Ecto.Changeset{}, field: :content)
      %Ecto.Changeset{}

  """
  @spec validate_draftjs_data(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_draftjs_data(changeset, opts) do
    fields = get_fields_from_opts(opts)

    validate_draftjs_fields(changeset, fields)
  end

  @spec get_fields_from_opts(Keyword.t()) :: [atom()]
  defp get_fields_from_opts(opts) do
    cond do
      Keyword.has_key?(opts, :field) -> [Keyword.fetch!(opts, :field)]
      Keyword.has_key?(opts, :fields) -> Keyword.fetch!(opts, :fields)
    end
  end

  @spec validate_draftjs_fields(Ecto.Changeset.t(), [atom()]) :: Ecto.Changeset.t()
  defp validate_draftjs_fields(changeset, fields) do
    Enum.reduce(fields, changeset, &validate_draftjs_field/2)
  end

  @spec validate_draftjs_field(atom(), Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_draftjs_field(field, changeset) do
    draftjs_data = Ecto.Changeset.get_change(changeset, field)

    if is_nil(draftjs_data) or valid_draftjs_data?(draftjs_data) do
      changeset
    else
      Ecto.Changeset.add_error(changeset, field, @invalid_draftjs_data_message)
    end
  end

  @spec valid_draftjs_data?(map()) :: boolean()
  defp valid_draftjs_data?(draftjs_data) do
    with true <- is_map(draftjs_data) do
      true
    else
      _ -> false
    end
  end
end
