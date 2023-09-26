defmodule BugsChannel.Utils.Vex do
  @moduledoc """
  This module is in charge of transforming vex errors to plain lists.
  """

  @doc ~S"""
  Parses event or list

  ## Examples

    iex> BugsChannel.Utils.Vex.translate_errors({:error, [{:error, :environment, :length, [message: "must have a length of at least 1", context: [value: nil, tokens: [], size: 0, min: 1, max: nil]]}, {:error, :stack_trace, :by, [message: "must be valid", context: [value: nil]]}, {:error, :level, :inclusion, [message: "must be one of [\"info\", \"warn\", \"error\", \"fatal\"]", context: [value: "", list: ["info", "warn", "error", "fatal"]]]}, {:error, :origin, :inclusion, [message: "must be one of [\"home\", \"sentry\"]", context: [value: "local", list: ["home", "sentry"]]]}, {:error, :tags, :by, [message: "must be valid", context: [value: nil]]}, {:error, :extra_args, :by, [message: "must be valid", context: [value: nil]]}]})
    ["environment: must have a length of at least 1", "stack_trace: must be valid", "level: must be one of [\"info\", \"warn\", \"error\", \"fatal\"]", "origin: must be one of [\"home\", \"sentry\"]", "tags: must be valid", "extra_args: must be valid"]

    iex> BugsChannel.Utils.Vex.translate_errors({:error, [{:error, :environment, [message: "must have a length of at least 1", context: [value: nil, tokens: [], size: 0, min: 1, max: nil]]}, {:error, :stack_trace, :by, [message: "must be valid", context: [value: nil]]}, {:error, :level, :inclusion, [message: "must be one of [\"info\", \"warn\", \"error\", \"fatal\"]", context: [value: "", list: ["info", "warn", "error", "fatal"]]]}, {:error, :origin, :inclusion, [message: "must be one of [\"home\", \"sentry\"]", context: [value: "local", list: ["home", "sentry"]]]}, {:error, :tags, :by, [message: "must be valid", context: [value: nil]]}, {:error, :extra_args, :by, [message: "must be valid", context: [value: nil]]}]})
    ["{:error, :environment, [message: \"must have a length of at least 1\", context: [value: nil, tokens: [], size: 0, min: 1, max: nil]]}", "stack_trace: must be valid", "level: must be one of [\"info\", \"warn\", \"error\", \"fatal\"]", "origin: must be one of [\"home\", \"sentry\"]", "tags: must be valid", "extra_args: must be valid"]

    iex> BugsChannel.Utils.Vex.translate_errors(:ok)
    []
  """
  def translate_errors({:error, errors}) do
    Enum.map(errors, fn error ->
      case error do
        {:error, field, _validator, result} ->
          message = if is_binary(result), do: result, else: result[:message]
          "#{field}: #{message}"

        error ->
          "#{inspect(error)}"
      end
    end)
  end

  def translate_errors(_ok), do: []

  @doc ~S"""
  Validate data and convert any errors to a plain list.

  ## Examples

    iex> BugsChannel.Utils.Vex.validate([foo: "bar"], foo: [ length: [ min: 10 ]])
    {:error, ["foo: must have a length of at least 10"]}

    iex> BugsChannel.Utils.Vex.validate([foo: "bar"], foo: [ length: [ min: 3 ]])
    {:ok, [foo: "bar"]}
  """
  def validate(params, validation_schema) do
    case Vex.validate(params, validation_schema) do
      {:ok, result} -> {:ok, result}
      errors -> {:error, translate_errors(errors)}
    end
  end
end
