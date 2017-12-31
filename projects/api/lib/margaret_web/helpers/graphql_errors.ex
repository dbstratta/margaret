defmodule MargaretWeb.Helpers.GraphQLErrors do
  @moduledoc """
  Helper functions for generating GraphQL errors.
  """

  @typep t :: Absinthe.Type.Field.error_result

  @doc """
  Creates an error tuple with a message.
  """
  @spec error_creator(String.t) :: t
  def error_creator(message), do: {:error, message}

  @doc """
  Return the `Unauthorized` error.
  """
  @spec unauthorized :: t
  def unauthorized, do: error_creator("Unauthorized")

  @doc """
  Return the `Something went wrong` error.
  """
  @spec something_went_wrong :: t
  def something_went_wrong, do: error_creator("Something went wrong")

  @doc """
  Return the `Not implemented` error.
  """
  @spec not_implemented :: t
  def not_implemented, do: error_creator("Not implemented")
end
