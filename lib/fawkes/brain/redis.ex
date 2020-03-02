defmodule Fawkes.Brain.Redis do
  @moduledoc """
  Redis Brain adapter. We store any elixir or erlang terms using etf.
  """

  def child_spec(opts) do
    %{
      id: opts[:name],
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts) do
    Redix.start_link(opts)
  end

  def get(name, key) do
    case Redix.command!(name, ["GET", key]) do
      nil ->
        nil

      value ->
        :erlang.binary_to_term(value)
    end
  end

  def set(name, key, value) do
    Redix.command(name, ["SET", key, :erlang.term_to_binary(value)])

    :ok
  end
end
