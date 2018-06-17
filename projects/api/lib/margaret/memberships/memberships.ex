defmodule Margaret.Memberships do
  @moduledoc """
  The Memberships context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Payments,
    Memberships
  }

  alias Accounts.User
  alias Memberships.Membership

  def get_membership(%User{id: user_id}),
    do: Repo.get_by(Membership, customer_id: user_id)

  @doc """
  Returns `true` if the user is a member.
  `false` otherwise.

  ## Examples

      iex> member?(%User{})
      true

  """
  @spec member?(User.t()) :: boolean()
  def member?(%User{} = user) do
    case get_membership(user) do
      %Membership{} = membership ->
        active?(membership)

      nil ->
        false
    end
  end

  defp active?(%Membership{} = _membership) do
    true
  end

  def start_membership(%User{} = user, opts) do
    source = Keyword.get(opts, :source)
    customer = Payments.get_or_insert_customer(user, %{source: source})

    attrs = %{customer_id: customer.id}
    insert_membership(attrs)
  end

  defp insert_membership(attrs) do
    Multi.new()
    |> create_stripe_subscription(attrs)
    |> insert_membership(attrs)
    |> Repo.transaction()
  end

  @spec create_stripe_subscription(Multi.t(), map()) :: Multi.t()
  defp create_stripe_subscription(multi, _attrs) do
    create_stripe_subscription_fn = fn _ ->
      params = %{}
      Stripe.Subscription.create(params)
    end

    Multi.run(multi, :stripe_subscription, create_stripe_subscription_fn)
  end

  @spec insert_membership(Multi.t(), map()) :: Multi.t()
  defp insert_membership(multi, _attrs) do
    insert_membership_fn = fn _changes ->
      attrs = %{}

      attrs
      |> Membership.changeset()
      |> Repo.insert()
    end

    Multi.run(multi, :membership, insert_membership_fn)
  end

  def cancel_membership(%User{} = user) do
    membership = get_membership(user)

    Multi.new()
    |> delete_stripe_subscription(membership)
    |> cancel_membership(membership)
    |> Repo.transaction()
  end

  defp delete_stripe_subscription(multi, membership) do
    delete_stripe_subscription_fn = fn _changes ->
      Stripe.Subscription.delete(membership.stripe_subscription_id)
    end

    Multi.run(multi, :stripe_subscription, delete_stripe_subscription_fn)
  end

  defp cancel_membership(multi, membership) do
    cancel_membership_fn = fn _changes ->
      delete_membership(membership)
    end

    Multi.run(multi, :membership, cancel_membership_fn)
  end

  defp delete_membership(%Membership{} = membership) do
    Repo.delete!(membership)
  end
end
