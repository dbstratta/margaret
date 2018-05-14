defmodule Margaret.Bookmarks.Policy do
  @moduledoc """
  Policy module for Bookmarks.
  """

  @behaviour Bodyguard.Policy

  alias Margaret.{
    Accounts
  }

  alias Accounts.User

  @impl Bodyguard.Policy
  def authorize(_action, %User{is_admin: true}, _), do: :ok
end
