defmodule Fawkes.Adapter.TestAdapter do
  @moduledoc """
  An adapter for developing and testing handlers.
  """
  use GenServer
  @behaviour Fawkes.Adapter

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def chat(text) do
    GenServer.call(__MODULE__, {:chat, text})
  end

  def say(_event, text) do
    GenServer.call(__MODULE__, {:say, text})
  end

  def reply(_event, text) do
    GenServer.call(__MODULE__, {:reply, text})
  end

  def code(_event, text) do
    GenServer.call(__MODULE__, {:code, text})
  end

  def init(state) do
    {:ok, Map.new(state)}
  end

  def handle_call({:chat, text}, _from, state) do
    Fawkes.EventProducer.notify(state.producer, %Fawkes.Event.Message{text: text})

    {:reply, :ok, state}
  end

  def handle_call({responder, text}, _from, state) when responder in [:say, :reply, :code] do
    send(state.parent, {responder, text})
    {:reply, :ok, state}
  end
end

