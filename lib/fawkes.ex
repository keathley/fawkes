defmodule Fawkes do
  @moduledoc """
  """
  use Supervisor

  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "Fawkes requires `:name`"
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    # TODO - Validate all of this with Norm.
    # TODO - Make this actually turn stuff on and like...work.
    handlers = opts[:handlers] || []
    adapter = opts[:adapter] || raise ArgumentError, "Fawkes requires :adapter"

    children = [
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
