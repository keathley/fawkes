defmodule Fawkes do
  @moduledoc """
  """
  use Supervisor

  alias Fawkes.EventProducer
  alias Fawkes.EventProcessor

  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "Fawkes requires `:name`"
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    # TODO - Validate all of this with Norm.
    name                    = opts[:name]
    handlers                = opts[:handlers] || []
    {adapter, adapter_args} = opts[:adapter] || raise ArgumentError, "Fawkes requires :adapter"

    event_handlers = for {handler, init} <- handlers do
      Supervisor.child_spec(
        {EventProcessor, [producer: producer_name(name), handler: {handler, init}]},
        id: :"fawkes_event_processor_#{handler}"
      )
    end

    pipeline = [{EventProducer, name: producer_name(name)} | event_handlers]

    children = pipeline ++ [
      {adapter, Keyword.put(adapter_args, :producer, producer_name(name))}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp producer_name(name) do
    :"#{name}.EventProducer"
  end
end
