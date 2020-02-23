defmodule Fawkes.Listener do
  @moduledoc false
  use Supervisor

  alias Fawkes.Listener.Store

  @sup Fawkes.Listener.WorkerSup

  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # TODO - Add support for `@here` messages with a giant warning to ensure
  # that people don't use this that often.

  def hear(re, command) do
    matcher = fn msg ->
      Regex.match?(re, msg.text)
    end

    c = fn msg ->
      list = Regex.run(re, msg.text) || []
      matches = Enum.drop(list, 1)
      msg = %{msg | matches: matches}
      command.(msg)
    end

    Store.add(matcher, c)
  end

  def respond(re, command) do
    matcher = fn msg ->
      bot_name = msg.bot_name
      bot_alias = msg.bot_alias

      cond do
        String.starts_with?(msg.text, "#{bot_name} ") ->
          Regex.match?(re, msg.text)

        String.starts_with?(msg.text, "#{bot_alias}") ->
          Regex.match?(re, msg.text)

        true ->
          false
      end
    end

    c = fn msg ->
      list = Regex.run(re, msg.text) || []
      matches = Enum.drop(list, 1)
      msg = %{msg | matches: matches}
      command.(msg)
    end

    Store.add(matcher, c)
  end

  def listen(matcher, command) do
    Store.add(matcher, command)
  end

  def handle_message(message) do
    Task.Supervisor.start_child(@sup, fn ->
      Logger.debug(fn -> "Handling message: #{inspect message}" end)

      # TODO - Make this work with the script builder stuff
      Store.listeners()
      |> Enum.filter(fn {matcher, _} -> matcher.(message) end)
      |> Enum.each(fn {_, command} -> command.(message) end)
    end)
  end

  def init(opts) do
    # Scripts must be a list of modules that export a listeners function that
    # returns the modules listeners
    listeners =
      opts[:scripts]
      |> Enum.flat_map(& &1.listeners())

    children = [
      {Fawkes.Listener.Store, listeners},
      {Task.Supervisor, name: @sup},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

