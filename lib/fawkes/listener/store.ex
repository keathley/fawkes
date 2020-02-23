defmodule Fawkes.Listener.Store do
  @moduledoc false
  # Provides a store for all of the listeners. This is available in ets so
  # its retrievable from any message processor.
  use GenServer

  def start_link(listeners) do
    GenServer.start_link(__MODULE__, listeners, name: __MODULE__)
  end

  def add(matcher, command) do
    GenServer.call(__MODULE__, {:add, matcher, command})
  end

  def listeners(table \\ __MODULE__) do
    case :ets.lookup(table, :listeners) do
      [] -> []
      [{:listeners, listeners}] -> listeners
    end
  end

  def init(listeners) do
    __MODULE__ = :ets.new(__MODULE__, [:set, :named_table, :protected])
    :ets.insert(__MODULE__, {:listeners, listeners})

    {:ok, %{table: __MODULE__, listeners: listeners}}
  end

  def handle_call({:add, matcher, command}, _from, state) do
    state = %{state | listeners: [{matcher, command} | state.listeners]}
    :ets.insert(__MODULE__, {:listeners, state.listeners})
    {:reply, :ok, state}
  end
end
