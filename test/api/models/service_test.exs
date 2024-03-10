defmodule BugsChannel.Api.Models.ServiceTest do
  use ExUnit.Case
  use Plug.Test

  import BugsChannel.Api.Models.Service

  describe "insert params" do
    test "valid model" do
      assert validate(:create, %{
               "name" => "service",
               "platform" => "elixir",
               "teams" => ~w(foo)
             }) == {:ok, %{name: "service", platform: "elixir", teams: ["foo"]}}
    end

    test "invalid model" do
      assert validate(:create, %{"foo" => "bar"}) ==
               {
                 :error,
                 %Ecto.Changeset{
                   action: :validate,
                   changes: %{},
                   constraints: [],
                   data: %{},
                   empty_values: [&Ecto.Type.empty_trimmed_string?/1],
                   errors: [
                     platform: {"can't be blank", [validation: :required]},
                     name: {"can't be blank", [validation: :required]}
                   ],
                   filters: %{},
                   params: %{"foo" => "bar"},
                   prepare: [],
                   repo: nil,
                   repo_opts: [],
                   required: [:platform, :name],
                   types: %{name: :string, platform: :string, teams: {:array, :string}},
                   valid?: false,
                   validations: []
                 }
               }
    end
  end

  describe "update params" do
    test "valid model" do
      assert validate(:update, %{
               "id" => "38c865300000000000000000",
               "name" => "service"
             }) == {:ok, %{name: "service", id: "38c865300000000000000000"}}
    end

    test "invalid model" do
      assert validate(:update, %{"foo" => "bar"}) ==
               {
                 :error,
                 %Ecto.Changeset{
                   action: :validate,
                   changes: %{},
                   constraints: [],
                   data: %{},
                   empty_values: [&Ecto.Type.empty_trimmed_string?/1],
                   errors: [
                     id: {"can't be blank", [validation: :required]}
                   ],
                   filters: %{},
                   params: %{"foo" => "bar"},
                   prepare: [],
                   repo: nil,
                   repo_opts: [],
                   required: [:id],
                   types: %{
                     name: :string,
                     platform: :string,
                     teams: {:array, :string},
                     id: :string
                   },
                   valid?: false,
                   validations: []
                 }
               }
    end
  end
end
