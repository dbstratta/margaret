defmodule Margaret.Accounts.SocialLogin do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: SocialLogin
  alias Margaret.Accounts.User

  @typedoc "The SocialLogin type"
  @type t :: %SocialLogin{
          uid: String.t,
          provider: String.t,
          user: User,
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
    |> cast(attrs, [:uid, :provider])
    |> validate_required([:uid, :provider])
    |> unique_constraint(:uid, name: :social_logins_uid_provider_index)
  end
end
