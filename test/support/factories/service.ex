defmodule BugsChannel.Factories.Service do
  @moduledoc """
  This is the module in charge of the test service structure.
  """

  use ExMachina

  alias BugsChannel.Factories.Team

  def service_factory do
    %BugsChannel.Repo.Schemas.Service{
      id: 1,
      name: "foo bar service",
      platform: "python",
      teams: [
        Team.team_factory()
      ],
      settings: service_settings_factory(),
      auth_keys: [
        service_auth_key_factory(),
        expired_service_auth_key_factory(),
        disabled_service_auth_key_factory()
      ]
    }
  end

  def service_settings_factory do
    %BugsChannel.Repo.Schemas.ServiceSettings{
      id: nil,
      rate_limit: 1
    }
  end

  def service_auth_key_factory do
    %BugsChannel.Repo.Schemas.ServiceAuthKey{
      key: "key",
      disabled: false,
      expired_at: nil
    }
  end

  defp expired_service_auth_key_factory() do
    %BugsChannel.Repo.Schemas.ServiceAuthKey{
      key: "expired_key",
      disabled: false,
      expired_at: ~D[2000-01-01]
    }
  end

  defp disabled_service_auth_key_factory() do
    %BugsChannel.Repo.Schemas.ServiceAuthKey{key: "disabled_key", disabled: true, expired_at: nil}
  end
end
