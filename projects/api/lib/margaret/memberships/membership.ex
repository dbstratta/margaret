defmodule Margaret.Memberships.Membership do
  @moduledoc """
  The Membership schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Payments
  }

  alias Payments.Customer

  @type t :: %Membership{}

  schema "membership" do
    belongs_to :customer, Customer
    field :stripe_subscription_id, :string

    field :ended_at, :naive_datetime

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a membership.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    permitted_attrs = ~w(
      user_id
      stripe_subscription_id
      ended_at
    )a

    required_attrs = ~w(
      user_id
      stripe_subscription_id
    )a

    %Membership{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:user)
  end

  @doc """
  Builds a changeset for updating a membership.
  """
  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%Membership{} = membership, attrs) do
    permitted_attrs = ~w(
      stripe_subscription_id
      ended_at
    )a

    membership
    |> cast(attrs, permitted_attrs)
  end
end
