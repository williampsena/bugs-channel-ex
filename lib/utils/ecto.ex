defmodule BugsChannel.Utils.Ecto do
  @moduledoc """
  This module is in charge of transforming ecto errors to plain lists.
  """

  @doc ~S"""
  Parses ecto changeset errors to list

  ## Examples

    iex> BugsChannel.Utils.Ecto.translate_errors({:ok, %Ecto.Changeset{ valid?: false, errors: [ project_id: {"is invalid", [type: :integer, validation: :cast]}, stack_trace: {"is invalid", [type: {:array, :map}, validation: :cast]} ] } })
    ["project_id: is invalid", "stack_trace: is invalid"]

    iex> BugsChannel.Utils.Ecto.translate_errors({:ok, %Ecto.Changeset{ valid?: false, errors: [ foo: :bar, project_id: {"is invalid", [type: :integer, validation: :cast]}, stack_trace: {"is invalid", [type: {:array, :map}, validation: :cast]} ] } })
    ["foo: :bar", "project_id: is invalid", "stack_trace: is invalid"]

    iex> BugsChannel.Utils.Ecto.translate_errors(:ok)
    []
  """
  def translate_errors({_, %Ecto.Changeset{errors: errors, valid?: false}}) do
    Enum.map(errors, fn {field, error} ->
      case error do
        {message, _opts} ->
          "#{field}: #{message}"

        error ->
          "#{field}: #{inspect(error)}"
      end
    end)
  end

  def translate_errors(_errors), do: []
end
