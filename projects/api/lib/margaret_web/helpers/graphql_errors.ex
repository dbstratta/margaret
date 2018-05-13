defmodule MargaretWeb.Helpers.GraphQLErrors do
  @moduledoc """
  Helper functions for generating GraphQL errors.
  """

  import Margaret.Helpers, only: [error: 1]

  @type t :: Absinthe.Type.Field.error_result()

  @doc """
  Returns the `Unauthorized` error.
  """
  @spec unauthorized :: t()
  def unauthorized, do: error("Unauthorized")

  @spec deactivated :: t()
  def deactivated, do: error("Your account was deactivated")

  @doc """
  Returns the `Something went wrong` error.
  """
  @spec something_went_wrong :: t()
  def something_went_wrong, do: error("Something went wrong")

  @doc """
  Returns the `Not implemented` error.
  """
  @spec not_implemented :: t()
  def not_implemented, do: error("Not implemented")

  @doc """
  Returns the `not found` error.
  """
  @spec not_found(String.t()) :: t()
  def not_found(thing), do: error("#{thing} not found")

  @spec story_not_found :: t()
  def story_not_found, do: not_found("Story")

  @spec comment_not_found :: t()
  def comment_not_found, do: not_found("Comment")

  @spec publication_not_found :: t()
  def publication_not_found, do: not_found("Publication")

  @spec invitation_not_found :: t()
  def invitation_not_found, do: not_found("Invitation")

  @spec user_not_found :: t()
  def user_not_found, do: not_found("User")
end
