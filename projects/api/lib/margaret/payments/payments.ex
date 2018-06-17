defmodule Margaret.Payments do
  @moduledoc """
  The Payments context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Payments
  }

  alias Accounts.User
  alias Payments.Customer

  def get_customer(%User{id: user_id}),
    do: Repo.get(Customer, user_id)

  def get_or_insert_customer(%User{} = user, attrs \\ %{}) do
    get_customer!(user)
  rescue
    _ ->
      attrs
      |> Map.put(:user_id, user.id)
      |> insert_customer()
  end

  defp get_customer!(%User{id: user_id}) do
    Repo.get!(Customer, user_id)
  end

  def insert_customer(attrs) do
    Multi.new()
    |> create_stripe_customer(attrs)
    |> insert_customer(attrs)
  end

  defp create_stripe_customer(multi, _attrs) do
    create_stripe_customer_fn = fn _changes ->
      params = %{}

      Stripe.Customer.create(params)
    end

    Multi.run(multi, :stripe_customer, create_stripe_customer_fn)
  end

  defp insert_customer(multi, attrs) do
    insert_customer_fn = fn _changes ->
      attrs
      |> Customer.changeset()
      |> Repo.insert()
    end

    Multi.run(multi, :customer, insert_customer_fn)
  end
end
