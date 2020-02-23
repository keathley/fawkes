defmodule Fawkes.EventProducer do
  @moduledoc false
  use GenStage

  require Logger

  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "Event Producer requires a unique name"
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def notify(name, event) do
    GenStage.cast(name, {:notify, event})
  end

  def init(_opts) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_cast({:notify, event}, {queue, pending_demand}) do
    queue = :queue.in(event, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
