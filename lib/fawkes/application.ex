defmodule Fawkes.Application do
  @moduledoc false

  use Application

  alias Vapor.Provider.{Dotenv, Env}
  alias Fawkes.EventProducer
  alias Fawkes.EventProcessor

  def start(_type, _args) do
    config = config!()

    handlers = [{Fawkes.TestHandler, 0}]

    event_handlers = for {handler, init} <- handlers do
      Supervisor.child_spec(
        {EventProcessor, [producer: EventProducer, handler: {handler, init}]},
        id: :"event_processor_#{handler}"
      )
    end

    event_pipeline = [{EventProducer, []} | event_handlers]

    children = event_pipeline ++ [
      {Fawkes.Adapter.Slack, token: config.slack_token},
    ]

    opts = [strategy: :one_for_one, name: Fawkes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def scripts do
    [
      # Fawkes.Scripts.Echo,
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
