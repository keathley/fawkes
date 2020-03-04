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

  def set_bot_name(server, name) do
    GenStage.call(server, {:set_bot_name, name})
  end

  def init(opts) do
    state = %{
      bot: opts[:bot],
      q: :queue.new(),
      demand: 0,
    }
    {:producer, state, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:set_bot_name, name}, _from, state) do
    state = %{state | bot: %{state.bot | bot_name: name}}
    # state = put_in(state, [:bot, :bot_name], name)
    {:reply, :ok, [], state}
  end

  def handle_cast({:notify, event}, state) do
    state = %{state | q: :queue.in(event, state.q)}
    dispatch_events(state, [])
  end

  def handle_demand(inc, state) do
    state = %{state | demand: state.demand + inc}
    dispatch_events(state, [])
  end

  defp dispatch_events(%{demand: 0}=state, events) do
    {:noreply, Enum.reverse(events), state}
  end

  defp dispatch_events(%{q: q, demand: demand}=state, events) do
    case :queue.out(q) do
      {{:value, event}, q} ->
        state = %{state | q: q, demand: demand - 1}
        event = %{event | bot: state.bot}
        dispatch_events(state, [event | events])

      {:empty, q} ->
        {:noreply, Enum.reverse(events), %{state | q: q}}
    end
  end
end
