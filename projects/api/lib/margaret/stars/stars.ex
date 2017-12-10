defmodule Margaret.Stars do
  @moduledoc """
  The Stars context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Stars.{Star, StoryStar}

  def create_star(attrs) do
    %Star{}
    |> Star.changeset(attrs)
    |> Repo.insert()
  end
end
