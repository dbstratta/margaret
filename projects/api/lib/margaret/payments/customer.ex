defmodule Margaret.Payments.Customer do
  @moduledoc """
  The Customer schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Accounts
  }

  alias Accounts.User

  @type t :: %Customer{}

  @primary_key false
  schema "customers" do
    belongs_to(:user, User, primary_key: true)

    field(:stripe_customer_id, :string)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a customer.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    permitted_attrs = ~w(
      user_id
      stripe_customer_id
    )a

    required_attrs = ~w(
      user_id
      stripe_customer_id
    )a

    %Customer{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
  end

  @doc """
  Builds a changeset for updating a customer.
  """
  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%Customer{} = customer, attrs) do
    permitted_attrs = ~w(
    )a

    customer
    |> cast(attrs, permitted_attrs)
  end
end
