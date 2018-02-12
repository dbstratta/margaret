defmodule MargaretWeb.Helpers.GraphQLErrors do
  @moduledoc """
  Helper functions for generating GraphQL errors.
  """

  @type t :: Absinthe.Type.Field.error_result()

  @doc """
  Creates an error tuple.
  """
  @spec error_creator(any()) :: t()
  def error_creator(reason), do: {:error, reason}

  @doc """
  Returns the `Unauthorized` error.
  """
  @spec unauthorized :: t()
  def unauthorized, do: error_creator("Unauthorized")

  @spec deactivated :: t()
  def deactivated, do: error_creator("Your account was deactivated")

  @doc """
  Returns the `Something went wrong` error.
  """
  @spec something_went_wrong :: t()
  def something_went_wrong, do: error_creator("Something went wrong")

  @doc """
  Returns the `Not implemented` error.
  """
  @spec not_implemented :: t()
  def not_implemented, do: error_creator("Not implemented")

  @doc """
  Returns the `doesn't exist` error.
  """
  @spec doesnt_exist(String.t()) :: t()
  def doesnt_exist(thing), do: error_creator("#{thing} doesn't exist")

  @spec story_doesnt_exist :: t()
  def story_doesnt_exist, do: doesnt_exist("Story")

  @spec publication_doesnt_exist :: t()
  def publication_doesnt_exist, do: doesnt_exist("Publication")

  @spec invitation_doesnt_exist :: t()
  def invitation_doesnt_exist, do: doesnt_exist("Invitation")

  @spec user_doesnt_exist :: t()
  def user_doesnt_exist, do: doesnt_exist("User")
end
