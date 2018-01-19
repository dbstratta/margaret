defmodule HelloWeb.AuthControllerTest do
  use MargaretWeb.ConnCase, async: true

  describe "GET /auth/facebook" do
    test "Responds with a status 302", %{conn: conn} do
      conn = get(conn, "/auth/facebook")

      response(conn, 302)
    end
  end

  describe "GET /auth/github" do
    test "Responds with a status 302", %{conn: conn} do
      conn = get(conn, "/auth/facebook")

      response(conn, 302)
    end
  end

  describe "GET /auth/google" do
    test "Responds with a status 302", %{conn: conn} do
      conn = get(conn, "/auth/facebook")

      response(conn, 302)
    end
  end
end
