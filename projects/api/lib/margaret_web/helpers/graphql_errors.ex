defmodule MargaretWeb.Helpers.GraphQLErrors do
  @moduledoc """
  Helper functions for generating GraphQL errors.
  """

  @typep error :: Absinthe.Type.Field.error_result

  @doc """
  Creates an error tuple with a message.
  """
  @spec error_creator(String.t) :: error
  def error_creator(message) do
    {:error, message}
  end

  @doc """
  Return the `Unauthorized` error.
  """
  @spec unauthorized :: error
  def unauthorized do
    error_creator("Unauthorized")
  end

  @doc """
  Return the `Resource not found` error.
  """
  @spec unauthorized :: error
  def unauthorized do
    error_creator("Unauthorized")
  end

  @doc """
  Return the `Something went wrong` error.
  """
  @spec something_went_wrong :: error
  def something_went_wrong do
    error_creator("Something went wrong")
  end

  @doc """
  Return the `Not implemented` error.
  """
  @spec not_implemented :: error
  def not_implemented do
    error_creator("Not implemented")
  end
end
