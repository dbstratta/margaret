defmodule Margaret.Comments.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Comment
  alias Margaret.Accounts.User

  @typedoc "The Comment type"
  @type t :: %Comment{}

  schema "abstract table: comments" do
    field :assoc_id, :integer
    field :body, :string
    belongs_to :author, User
    has_many :comments, {"comment_comments", Comment}, foreign_key: :assoc_id

    timestamps()
  end
end
