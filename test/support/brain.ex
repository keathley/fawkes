defmodule Fawkes.TestHandlers.Brain do
  @moduledoc false
  use Fawkes.Listener

  @help """
  set <value> in <key> - Sets the value in the key in the bot's brain
  """
  hear ~r/set (.*) in (.*)/, fn [value, key], event ->
    result = Fawkes.Bot.set(event.bot, key, value)
    if result == :ok do
      say(event, "Ok, I set '#{key}'")
    else
      say(event, "Something went wrong")
    end
  end

  @help """
  get <key> - Gets the value from the bots brain
  """
  hear ~r/get (.*)/, fn [key], event ->
    {:ok, val} = Fawkes.Bot.get(event.bot, key)
    say(event, "The value of '#{key}' is '#{val}'")
  end
end
