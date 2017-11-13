defmodule MargaretWeb.PageController do
  use MargaretWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
