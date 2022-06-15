defmodule AriaWeb.Lives.Seesion.LoginLiveTest do
    use AriaWeb.ConnCase

    import Aria.AccountsFixtures
    import Phoenix.LiveViewTest

    @valid_email unique_user_email()
    @valid_password valid_user_password()

    describe "GET /users/log_in" do
        test "registers new user", %{conn: conn} do
            {:ok, new_live, html} = live(conn, Routes.login_path(conn, :login))
      
            assert html =~ "Continue with Github"
            assert html =~ "Sign in"
            assert html =~ "Register"
      
            form = form(new_live, "#login-form", user: %{email: @valid_email, password: @valid_password})

            assert render_submit(form) =~ ~r/phx-trigger-action/
            conn = follow_trigger_action(form, conn)
            assert conn.method == "POST"
            assert conn.params == %{"user" => %{"email" => @valid_email, "password" => @valid_password}}
        
        end
    end
end