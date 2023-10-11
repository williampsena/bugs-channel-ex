defmodule BugsChannel.Settings.Schemas.ConfigFile do
  @moduledoc """
  The module represents a configuration file struct.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias BugsChannel.Repo.Schemas, as: RepoSchemas

  schema "config_file" do
    field(:version, :string)
    field(:org, :string)

    embeds_many(:services, RepoSchemas.Service)
    embeds_many(:teams, RepoSchemas.Team)
  end

  @doc ~S"""
  Parses config file to Ecto Changeset

  ## Examples

      iex> BugsChannel.Settings.Schemas.ConfigFile.changeset(%BugsChannel.Settings.Schemas.ConfigFile{}, %{ "version" => "1", "org" => "Foo", "services" => [ %{"id" => 1, "name" => "bar", "platform" => "python", "team" => "foo", "settings" => %{ "rate_limit" => 1, "auth-keys" => [ %{"key" => "key"}]} } ], "teams" => [ %{"id" => 1, "name" => "Foo"} ]  }).valid?
      true

      iex> BugsChannel.Settings.Schemas.ConfigFile.changeset(%BugsChannel.Settings.Schemas.ConfigFile{}, %{ "id" => "foo" }).valid?
      false

      iex> BugsChannel.Settings.Schemas.ConfigFile.changeset(%BugsChannel.Settings.Schemas.ConfigFile{}).valid?
      false
  """

  def changeset(%__MODULE__{} = config_file, params \\ %{}) do
    config_file
    |> cast(params, ~w(id version org)a)
    |> cast_embed(:services, required: true)
    |> cast_embed(:teams, required: true)
    |> validate_required(~w(version org)a)
    |> validate_length(:version, min: 1)
    |> validate_length(:org, min: 3)
  end

  @doc ~S"""
  Parses config file

  ## Examples

      iex> BugsChannel.Settings.Schemas.ConfigFile.parse(%{ "version" => "1", "org" => "Foo", "services" => [ %{"id" => 1, "name" => "bar", "platform" => "python", "team" => "foo", "settings" => %{ "rate_limit" => 1}, "auth_keys" => [ %{"key" => "key"} ]  } ], "teams" => [ %{"id" => 1, "name" => "Foo"} ]  })
      {
        :ok,
        %BugsChannel.Settings.Schemas.ConfigFile{
          org: "Foo",
          services: [
            %BugsChannel.Repo.Schemas.Service{
              id: 1,
              name: "bar",
              platform: "python",
              auth_keys: [
                %BugsChannel.Repo.Schemas.ServiceAuthKey{
                  id: nil,
                  key: "key",
                  disabled: false,
                  expired_at: nil
                }
              ],
              settings: %BugsChannel.Repo.Schemas.ServiceSettings{ id: nil, rate_limit: 1},
              team: "foo"
            }
          ],
          teams: [
            %BugsChannel.Repo.Schemas.Team{
              id: 1,
              name: "Foo"
            }
          ],
          version: "1"
        }
      }

      iex> {:error, changeset } = BugsChannel.Settings.Schemas.ConfigFile.parse(%{ "id" => "foo" })
      iex> [changeset.valid?, changeset.errors]
      [false, [
        version: {"can't be blank", [validation: :required]},
        org: {"can't be blank", [validation: :required]},
        teams: {"can't be blank", [validation: :required]},
        services: {"can't be blank", [validation: :required]},
        id: {"is invalid", [type: :id, validation: :cast]}
      ]]
  """
  def parse(params) when is_map(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:update)
  end
end
