defmodule Margaret.Accounts.SocialLogin do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.Accounts.User

  @type t :: %SocialLogin{}

  @permitted_attrs [
    :uid,
    :provider,
    :user_id
  ]

  @required_attrs [
    :uid,
    :provider,
    :user_id
  ]

  schema "social_logins" do
    field(:uid, :string)
    field(:provider, :string)
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %SocialLogin{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:uid, name: :social_logins_uid_provider_index)
    |> foreign_key_constraint(:user_id)
  end
end
