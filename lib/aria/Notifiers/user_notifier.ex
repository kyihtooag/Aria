defmodule Aria.Notifiers.UserNotifier do
  import Swoosh.Email

  alias Aria.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Aria", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver one time passcode for the .
  """
  def deliver_one_time_passcode(user, otp) do
    deliver(user.email, "One Time Passcode", """

    ==============================

    Hi #{user.email},

    You can confirm your actions by enter the following token:

    #{otp}

    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_instruction_link(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
