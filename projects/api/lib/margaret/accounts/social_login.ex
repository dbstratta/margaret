defmodule Margaret.Accounts.SocialLogin do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.Accounts.User

  @typedoc "The SocialLogin type"
  @type t :: %SocialLogin{
          uid: String.t,
          provider: String.t,
        }

  schema "social_logins" do
    field :uid, :string
    field :provider, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%SocialLogin{} = social_login, attrs) do
    social_login
    |> cast(attrs, [:uid, :provider, :user_id])
    |> validate_required([:uid, :provider, :user_id])
    |> unique_constraint(:uid, name: :social_logins_uid_provider_index)
    |> foreign_key_constraint(:user_id)
  end
end
