defmodule Margaret.Stories do
  @moduledoc """
  The Stories context.
  """

  import Ecto.Query

  alias Margaret.Repo
  alias Margaret.Stories.Story

  def get_story(slug) do
    Repo.get_by(Story, slug: slug)
  end

  def create_story(attrs) do
    %Story{}
    |> Story.changeset(attrs)
    |> Repo.insert()
  end
end
