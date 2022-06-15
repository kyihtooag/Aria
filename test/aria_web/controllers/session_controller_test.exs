defmodule AriaWeb.SessionControllerTest do
  use AriaWeb.ConnCase, async: true

  import Aria.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.session_path(conn, :login), %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ "Log Out"
    end

    # test "logs the user in with remember me", %{conn: conn, user: user} do
    #   conn =
    #     post(conn, Routes.user_session_path(conn, :login), %{
    #       "user" => %{
    #         "email" => user.email,
    #         "password" => valid_user_password(),
    #         "remember_me" => "true"
    #       }
    #     })

    #   assert conn.resp_cookies["_demo_web_user_remember_me"]
    #   assert redirected_to(conn) == "/"
    # end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(Routes.session_path(conn, :login), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.session_path(conn, :login), %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      assert "/login" = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Invalid email or password"
    end
  end

  describe "GET /log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.session_path(conn, :logout))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :logout))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
