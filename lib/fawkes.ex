defmodule Fawkes do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  use Supervisor

  alias Fawkes.Bot
  alias Fawkes.Brain
  alias Fawkes.EventProducer
  alias Fawkes.EventProcessor

  @doc """
  Starts a new robot.
  """
  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "Fawkes requires `:name`"
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @doc false
  def init(opts) do
    # TODO - Validate all of this with Norm.
    name                    = opts[:name]
    handlers                = opts[:handlers] || []
    {adapter, adapter_args} = opts[:adapter] || raise ArgumentError, "Fawkes requires :adapter"
    {brain, brain_args}     = opts[:brain] || {Brain.InMemory, []}

    bot = %Bot{
      id: name,
      adapter: adapter,
      adapter_name: adapter_name(name),
      bot_name: opts[:bot_name],
      bot_alias: opts[:bot_alias],
      brain: brain,
      brain_name: brain_name(name),
    }

    handler_modules =
      handlers
      |> Enum.map(fn {mod, _} -> mod end)

    handler_modules = Enum.concat([Fawkes.Handlers.Help], handler_modules)
    handlers = [{Fawkes.Handlers.Help, handler_modules} | handlers]

    event_handlers = for {handler, init} <- handlers do
      Supervisor.child_spec(
        {EventProcessor, [
          bot: bot,
          producer: producer_name(name),
          handler: {handler, init}
        ]},
        id: :"fawkes_event_processor_#{handler}"
      )
    end

    producer_opts = [
      name: producer_name(name),
      bot: bot,
    ]
    pipeline = [{EventProducer, producer_opts} | event_handlers]

    adapter_args =
      adapter_args
      |> Keyword.put(:producer, producer_name(name))
      |> Keyword.put(:adapter_options, [name: adapter_name(name)])

    brain_args =
      brain_args
      |> Keyword.put(:name, brain_name(name))

    http_client = {Finch, name: Fawkes.HTTPClient}

    children = [http_client, {brain, brain_args}] ++ pipeline ++ [{adapter, adapter_args}]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp producer_name(name) do
    :"#{name}.EventProducer"
  end

  defp brain_name(name) do
    :"#{name}.Brain"
  end

  defp adapter_name(name) do
    :"#{name}.Adapter"
  end
end
