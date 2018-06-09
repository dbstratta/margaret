defmodule Margaret.Stories.Policy do
  @moduledoc """
  Policy module for Stories.

  TODO: Think how to decouple modules (Publications)
  and still use their functions here.
  """

  @behaviour Bodyguard.Policy

  alias Margaret.{
    Accounts
  }

  alias Accounts.User

  @impl Bodyguard.Policy
  def authorize(_action, %User{is_admin: true}, _params), do: :ok

  def authorize(:see_story, user, story) do
    cond do
      user.id === story.author_id ->
        :ok

      true ->
        :error
    end
  end

  def authorize(:update_story, user, story) do
    if user.id === story.author_id do
      :ok
    else
      :error
    end
  end

  def authorize(:delete_story, user, story) do
    if user.id === story.author_id do
      :ok
    else
      :error
    end
  end
end
