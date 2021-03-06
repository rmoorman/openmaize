Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Openmaize.PhxTest do
  use ExUnit.Case
  import MixHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates default html resource" do
    in_tmp "generates default html resource", fn ->
      Mix.Tasks.Openmaize.Phx.run []

      assert_file "web/controllers/authorize.ex"
      assert_file "web/templates/session/new.html.eex"

      assert_file "web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:create]"
        refute file =~ "def confirm_email(%Plug.Conn{private: %{openmaize_error: message}}"
      end

      assert_file "web/views/user_view.ex", fn file ->
        refute file =~ "%{info: %{detail: message}}"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ "defmodule OpenmaizePhx.Router"
        assert file =~ "plug Openmaize.Authenticate"
        assert file =~ ~s(resources "/sessions", SessionController)
        assert file =~ ~s(resources "/users", UserController)
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s({:openmaize, "~> 2.7"})
      assert message =~ ~s(And to start the server)
    end
  end

  test "generates confirm functionality" do
    in_tmp "generates confirm functionality", fn ->
      Mix.Tasks.Openmaize.Phx.run ["--confirm"]

      assert_file "lib/openmaize_phx/mailer.ex"
      assert_file "web/controllers/authorize.ex"

      assert_file "web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:create]"
        assert file =~ "def confirm_email(%Plug.Conn{private: %{openmaize_error: message}}"
      end

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "plug :user_check when action in [:index, :show]"
        assert file =~ "plug :id_check when action in [:edit, :update, :delete]"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ ~s(resources "/sessions", SessionController)
        assert file =~ ~s(get "/sessions/confirm_email", SessionController)
        assert file =~ ~s(resources "/password_resets", PasswordResetController)
      end
    end
  end

  test "generates api files" do
    in_tmp "generates api files", fn ->
      Mix.Tasks.Openmaize.Phx.run ["--api"]

      assert_file "web/views/auth_view.ex"
      assert_file "web/views/changeset_view.ex"
      assert_file "web/controllers/auth.ex"

      assert_file "web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:create]"
        assert file =~ ~s(OpenmaizePhx.AuthView, "401.json", [])
      end

      assert_file "web/views/user_view.ex", fn file ->
        assert file =~ "%{info: %{detail: message}}"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ "plug :verify_token"
        assert file =~ ~s(post "/sessions/create", SessionController, :create)
        assert file =~ ~s(resources "/users", UserController, except: [:new, :edit])
      end
    end
  end

  test "generates api files with confirm" do
    in_tmp "generates api files with confirm", fn ->
      Mix.Tasks.Openmaize.Phx.run ["--api", "--confirm"]

      assert_file "web/views/auth_view.ex"
      assert_file "web/views/changeset_view.ex"
      assert_file "web/controllers/auth.ex"

      assert_file "web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:create]"
        assert file =~ ~s(OpenmaizePhx.AuthView, "401.json", [])
      end

      assert_file "web/views/user_view.ex", fn file ->
        assert file =~ "%{info: %{detail: message}}"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ "plug :verify_token"
        assert file =~ ~s(post "/sessions/create", SessionController, :create)
        assert file =~ ~s(resources "/users", UserController, except: [:new, :edit])
      end
    end
  end

end
