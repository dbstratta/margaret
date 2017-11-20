defmodule MargaretWeb.Guardian do
  use Guardian, otp_app: :margaret

  alias Margaret.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    {:ok, "User:" <> to_string(user.id)}
  end
  def subject_for_token(_, _) do
    {:error, :unknown_resource}
  end

  def resource_from_claims(%{"sub" => "User:" <> user_id_string}) do
    with {user_id, ""} <- Integer.parse(user_id_string),
         {:ok, user} <- User.get_user(user_id) do
      {:ok, user}
    else
      :error -> {:error, :invalid_id}
      {:error, _} -> {:error, :no_result}
    end
  end
  def resource_from_claims(_) do
    {:error, :invalid_claims}
  end
end
