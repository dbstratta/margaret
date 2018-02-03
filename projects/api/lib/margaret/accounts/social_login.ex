defmodule Margaret.Accounts.SocialLogin do
  @moduledoc """
  The Social Login schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.Accounts.User

  @type t :: %SocialLogin{}

  schema "social_logins" do
    # The user id from the provider.
    field(:uid, :string)
    # Providers are Facebook, Google, GitHub, etc.
    field(:provider, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a social login.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      uid
      provider
      user_id
    )a

    required_attrs = ~w(
      uid
      provider
      user_id
    )a

    %SocialLogin{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:uid, name: :social_logins_uid_provider_index)
    |> assoc_constraint(:user)
  end
end
