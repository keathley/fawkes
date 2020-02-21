defmodule Fawkes.Listener do
  @moduledoc false
  use Supervisor

  alias Fawkes.Listener.Worker

  @sup Fawkes.Listener.WorkerSup

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def handle_message(message) do
    IO.inspect(message, label: "Got a message")
    DynamicSupervisor.start_child(@sup, {Worker, message})
  end

  def init(opts) do
    # Scripts must be a list of modules that export a listeners function that
    # returns the modules listeners
    listeners =
      opts[:scripts]
      |> Enum.flat_map(& &1.listeners())

    children = [
      {Fawkes.Listener.Store, listeners},
      {DynamicSupervisor, strategy: :one_for_one, name: @sup},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

