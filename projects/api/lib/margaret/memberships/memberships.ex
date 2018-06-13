defmodule Margaret.Memberships do
  @moduledoc """
  The Memberships context.
  """

  alias Margaret.{
    Accounts
  }

  alias Accounts.User

  @spec member?(User.t()) :: boolean()
  def member?(%User{} = _user) do
    false
  end

  def start_membership(%User{} = _user) do
  end

  def cancel_membership(%User{} = _user) do
  end
end
