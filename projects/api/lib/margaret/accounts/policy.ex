defmodule Margaret.Accounts.Policy do
  @moduledoc """
  Policy module for Accounts.
  """

  @behaviour Bodyguard.Policy

  import Margaret.Helpers
  alias Margaret.Accounts
  alias Accounts.User

  @impl Bodyguard.Policy
  def authorize(_action, %User{is_admin: true}, _), do: :ok

  def authorize(:update_user, %User{id: requester_id}, %{id: requester_id}), do: :ok
  def authorize(:update_user, _requester, _user), do: error("Unauthorized")
end
