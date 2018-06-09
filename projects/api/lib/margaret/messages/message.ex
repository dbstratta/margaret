defmodule Margaret.Messages.Message do
  @moduledoc """
  The Message schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Accounts.User,
    Helpers
  }

  @type t :: %Message{}

  schema "messages" do
    # `content` is rich text and contains metadata, so we store it as a map.
    field(:content, :map)

    belongs_to(:sender, User)
    belongs_to(:recipient, User)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a message.

  ## Examples

      iex> changeset(attrs)
      %Ecto.Changeset{}

  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    permitted_attrs = ~w(
      content
      sender_id
      recipient_id
    )a

    required_attrs = ~w(
      content
      sender_id
      recipient_id
    )a

    %Message{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> Helpers.DraftJS.validate_draftjs_data(field: :content)
    |> assoc_constraint(:sender)
    |> assoc_constraint(:recipient)
  end
end
