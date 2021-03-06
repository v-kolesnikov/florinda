defmodule FlorindaCtl.Auth.UserRegistrationControllerTest do
  use FlorindaCtl.ConnCase, async: true

  import Florinda.AccountsFixtures

  describe "GET /auth/users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.auth_user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Create your Florinda account"
      assert response =~ "Create account"
      assert response =~ "Sign in</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.auth_user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /auth/users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, Routes.auth_user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(email: email)
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.auth_user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "short"}
        })

      response = html_response(conn, 200)
      assert response =~ "Create your Florinda account"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 6 character"
    end
  end
end
