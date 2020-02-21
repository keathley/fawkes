defmodule Fawkes.Application do
  @moduledoc false

  use Application

  alias Vapor.Provider.{Dotenv, Env}

  def start(_type, _args) do
    config = config!()

    children = [
      {Fawkes.Listener, scripts: scripts()},
      {Fawkes.Slack, token: config.slack_token},
    ]

    opts = [strategy: :one_for_one, name: Fawkes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def scripts do
    [
      Fawkes.Scripts.Echo,
    ]
  end

  def config! do
    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          slack_token: "SLACK_TOKEN"
        ]
      },
    ]
    Vapor.load!(providers)
  end
end
