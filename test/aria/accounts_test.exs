defmodule Aria.AccountsTest do
  use Aria.DataCase

  import Aria.AccountsFixtures
  alias Aria.Accounts
  alias Aria.Accounts.{User, UserToken}
  alias Aria.Repo

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_one_time_passcode/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends otp through email", %{user: user} do
      otp = extract_otp(Accounts.deliver_one_time_passcode(user, "confirm"))

      assert user_token = Repo.get_by(UserToken, %{otp: otp, context: "confirm"})
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end

    test "will not send otp through email if the user is already confirm" do
      assert {:error, :already_confirmed} =
               Accounts.deliver_one_time_passcode(%User{is_confirmed: true}, "confirm")
    end
  end

  describe "validate_one_time_passcode/2" do
    setup do
      user = user_fixture()

      otp = extract_otp(Accounts.deliver_one_time_passcode(user, "confirm"))

      %{user: user, otp: otp}
    end

    test "returns the user with valid otp", %{user: %{id: id}, otp: otp} do
      assert {:ok, %User{id: ^id}} = Accounts.validate_one_time_passcode(otp, "confirm")
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid otp", %{user: user} do
      assert Accounts.validate_one_time_passcode("oops", "confirm") == :error
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if otp expired", %{user: user, otp: otp} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.validate_one_time_passcode(otp, "confirm") == :error
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_instruction_link/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_url_token(fn url ->
          Accounts.deliver_instruction_link(user, "reset_password", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "validate_url_token/2" do
    setup do
      user = user_fixture()

      token =
        extract_url_token(fn url ->
          Accounts.deliver_instruction_link(user, "reset_password", url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.validate_url_token(token, "reset_password")
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.validate_url_token("oops", "reset_password")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.validate_url_token(token, "reset_password")
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "confirm_user/1" do
    setup do
      user = user_fixture()

      otp = extract_otp(Accounts.deliver_one_time_passcode(user, "confirm"))

      %{user: user, otp: otp}
    end

    test "confirms the email with a valid otp", %{user: user, otp: otp} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(otp)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid otp", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm email if otp expired", %{user: user, otp: otp} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(otp) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end
end
