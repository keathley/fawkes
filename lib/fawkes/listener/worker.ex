defmodule Fawkes.Listener.Worker do
  @moduledoc false
  # GenServer designed to run exactly one message and die.
  use GenServer, restart: :temporary

  alias Fawkes.Listener.Store

  def start_link(message) do
    IO.inspect(message, label: "Starting worker")
    GenServer.start_link(__MODULE__, message)
  end

  def init(message) do
    IO.puts "Started the process"
    {:ok, message, {:continue, :run}}
  end

  def handle_continue(:run, message) do
    IO.inspect(message, label: "Running!!!")
    Enum.each Store.listeners(), fn listener ->
      case Regex.run(listener.regex, message.text) do
        nil -> :done

        list ->
          matches = Enum.drop(list, 1)
          listener.func.(%{message | matches: matches})
      end
    end

    {:stop, :completed, message}
  end
end

