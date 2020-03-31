defmodule Fawkes.Brain.InMemory do
  @moduledoc """
  In memory brain adapter. This is only used for development and test purposes.
  """
  use GenServer
  @behaviour Fawkes.Brain

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def get(name, key) do
    GenServer.call(name, {:get, key})
  end

  def set(name, key, value) do
    GenServer.call(name, {:set, key, value})
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:get, key}, _from, data) do
    {:reply, data[key], data}
  end

  def handle_call({:set, key, value}, _from, data) do
    {:reply, :ok, Map.put(data, key, value)}
  end
end
