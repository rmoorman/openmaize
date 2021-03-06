defmodule Openmaize.Utils do
  @moduledoc false

  @doc """
  Get the default name for the repo.
  """
  def default_repo do
    base_module() |> Module.concat(Repo)
  end

  @doc """
  Get the default name for the user_model.
  """
  def default_user_model do
    base_module() |> Module.concat(User)
  end

  @doc """
  Get the mix project module name.
  """
  def base_module do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string |> Macro.camelize
  end
end
