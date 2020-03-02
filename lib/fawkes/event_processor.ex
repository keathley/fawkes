defmodule Fawkes.EventProcessor do
  @moduledoc false
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  def init(opts) do
    producer        = opts[:producer] || raise ArgumentError
    {handler, args} = opts[:handler] || raise ArgumentError

    case handler.init(args) do
      {:ok, init} ->
        state = %{
          handler: handler,
          handler_state: init,
        }
        {:consumer, state, subscribe_to: [producer]}
    end
  end

  def handle_events(events, _from, state) do
    new_state = Enum.reduce(events, state.handler_state, fn event, new_state ->
      state.handler.handle_event(event, new_state)
    end)

    {:noreply, [], %{state | handler_state: new_state}}
  end
end
