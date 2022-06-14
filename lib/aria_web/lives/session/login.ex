defmodule AriaWeb.Session.LoginLive do
  use AriaWeb, :live_view

  alias Aria.Accounts

  def mount(_params, _session, socket) do
    changeset = Accounts.user_changeset()

    {
      :ok,
      socket
      |> assign(:changeset, changeset)
      |> assign(:trigger_submit, false)
    }
  end

  def render(assigns),
    do: Phoenix.View.render(AriaWeb.SessionView, "login.html", assigns)

  def handle_event("save", %{"user" => user_params}, socket) do
    user_params
    |> Accounts.user_changeset()
    |> Map.put(:action, :validate)
    |> case do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, changeset: changeset, trigger_submit: true)}

      %{valid?: false} = changeset ->
        {:noreply, assign(socket, changeset: changeset, trigger_submit: false)}
    end
  end
end
