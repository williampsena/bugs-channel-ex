defmodule BugsChannel.Api.Views.Error do
  @moduledoc """
  This view is in responsible to translate errors
  """
  require Logger

  alias BugsChannel.Utils.Ecto, as: EctoUtils

  @doc ~S"""
  Render PagedResults to an encodable map

  ## Examples

      iex> BugsChannel.Api.Views.Error.render_error("some error")
      %{"error" => "some error"}

      iex> BugsChannel.Api.Views.Error.render_error(%{ "detail" => "some error" })
      %{"error" => %{ "detail" => "some error"} }

      iex> BugsChannel.Api.Views.Error.render_error(["some error"])
      %{"error" => ["some error"] }

      iex> BugsChannel.Api.Views.Error.render_error(:some_error)
      %{"error" => "unknown error", "detail" => ":some_error"}

      iex> BugsChannel.Api.Views.Error.render_error({:error, "some error"})
      %{"error" => "some error"}

      iex> BugsChannel.Api.Views.Error.render_error({:error, "some error", "detail"})
      %{"error" => "unknown error", "detail" => "{\"some error\", \"detail\"}"}
  """

  def render_error({:error, message}) do
    render_error(message)
  end

  def render_error({:error, message, opts}) do
    render_error({message, opts})
  end

  def render_error(message) when is_binary(message) or is_map(message) or is_list(message) do
    %{"error" => message}
  end

  def render_error(message) do
    %{"error" => "unknown error", "detail" => inspect(message)}
  end

   @doc ~S"""
  Render PagedResults to an encodable map

  ## Examples

      iex> BugsChannel.Api.Views.Error.render_ecto_error("some error")
      %{"error" => "some error"}

      iex> BugsChannel.Api.Views.Error.render_ecto_error(%Ecto.Changeset{ valid?: false, errors: [ foo: :bar, service_id: {"is invalid", [type: :integer, validation: :cast]}, stack_trace: {"is invalid", [type: {:array, :map}, validation: :cast]} ] })
      %{ "error" => ["foo: :bar", "service_id: is invalid", "stack_trace: is invalid"] }
  """
  def render_ecto_error(%Ecto.Changeset{valid?: false} = changeset) do
    %{"error" => EctoUtils.translate_errors(changeset)}
  end

  def render_ecto_error(message) do
    render_error(message)
  end
end
