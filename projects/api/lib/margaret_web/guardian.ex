defmodule MargaretWeb.Guardian do
  @moduledoc """
  Guardian implementation module.
  """

  use Guardian, otp_app: :margaret

  alias Margaret.Accounts
  alias Accounts.User

  @doc """
  Returns the subject for the JWT token.

  ## Examples

    iex> subject_for_token(%User{}, %{})
    {:ok, 123}

    iex> subject_for_token(%{}, %{})
    {:error, :unknown_resource}

  """
  def subject_for_token(%User{id: user_id}, _claims), do: {:ok, user_id}
  def subject_for_token(_, _), do: {:error, :unknown_resource}

  @doc """
  Retrieves the resource (User) from the token claim `sub`.

  ## Examples

    iex> resource_from_claims(%{"sub" => 123})
    {:ok, %User{}}

    iex> resource_from_claims(%{"sub" => 456})
    {:error, :invalid_credentials}

  """
  def resource_from_claims(%{"sub" => user_id}) do
    resource = Accounts.get_user!(user_id)

    {:ok, resource}
  rescue
    _ -> {:error, :invalid_credentials}
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}
end
