defmodule Margaret.Payments do
  @moduledoc """
  The Payments context.
  """

  alias Margaret.{
    Repo,
    Payments
  }

  alias Payments.Customer

  def insert_customer(attrs) do
    attrs
    |> Customer.changeset()
    |> Repo.insert()
  end
end
