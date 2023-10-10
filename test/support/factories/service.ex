defmodule BugsChannel.Factories.Service do
  @moduledoc """
  This is the module in charge of the test service structure.
  """

  use ExMachina

  def service_factory do
    %BugsChannel.Repo.Schemas.Service{
      id: 1,
      name: "foo bar service",
      platform: "python",
      team: "foo",
      settings: service_settings_factory(),
      auth_keys: [
        service_auth_key_factory()
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
    %BugsChannel.Repo.Schemas.ServiceAuthKeys{
      key: "key",
      disabled: false,
      expired_at: nil
    }
  end
end
