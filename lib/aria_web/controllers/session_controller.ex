defmodule AriaWeb.SessionController do
  use AriaWeb, :controller

  alias Aria.Accounts
  alias AriaWeb.Plugs.UserAuth

  def login(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      conn
      |> put_flash(:error, "Invalid email or password")
      |> render("new.html")
    end
  end
end
