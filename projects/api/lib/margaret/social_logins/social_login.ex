defmodule Margaret.SocialLogins.SocialLogin do
  @moduledoc """
  The Social Login schema and changesets.

  Users can sign in through OAuth2 providers,
  so we need to store those credentials.
  A social login serves that porpouse.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.Accounts.User

  @type t :: %SocialLogin{}

  schema "social_logins" do
    # The user id from the provider.
    field(:uid, :string)
    # provider can be "facebook", "google", "github", etc.
    field(:provider, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a social login.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
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
