defmodule AriaWeb.PageController do
  use AriaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
