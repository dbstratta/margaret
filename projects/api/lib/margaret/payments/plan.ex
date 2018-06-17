defmodule Margaret.Payments.Plan do
  @moduledoc """

  """

  @enforce_keys [:stripe_plan_id]
  defstruct [:stripe_plan_id]
end
