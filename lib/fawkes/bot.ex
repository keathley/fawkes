defmodule Fawkes.Bot do
  @moduledoc """
  Provides convenience functions for responding to different events.
  """
  defstruct ~w|id bot_name bot_alias adapter adapter_name brain brain_name|a

  alias Fawkes.Event.Message

  @type t :: %__MODULE__{}

  @doc """
  Sends a text message back to the channel the event originated from.
  """
  def say(%{bot: bot}=event, text) do
    bot.adapter.say(event, text)
  end

  @doc """
  Mentions the user who created the event with the specified text.
  """
  def reply(%{bot: bot}=event, text) do
    bot.adapter.reply(event, text)
  end

  @doc """
  Sends a message to the event's channel, formatted as a code snippet.
  """
  def code(%{bot: bot}=event, text) do
    bot.adapter.code(event, text)
  end

  # @doc """
  # Message everyone in the event's channel. This is typically equivalent to an
  # `@here` message.
  # """
  # def message_channel(bot, text) do
  #   bot.adapter.message_channel(bot.id, text)
  # end

  def set(%{bot: bot}, key, value) do
    bot.brain.set(bot.brain_name, key, value)
  end

  def get(%{bot: bot}, key) do
    bot.brain.get(bot.brain_name, key)
  end

  @doc """
  Defines a listener that will only trigger if the bot was mentioned and
  the regex pattern is matched. Respond assumes that the message mentions the
  bot as the first part of text.
  """
  def respond(%Message{text: text}=event, state, regex, cb) do
    text = cond do
      String.starts_with?(text, event.bot.bot_name) ->
        String.trim_leading(text, event.bot.bot_name)

      event.bot.bot_alias && String.starts_with?(text, event.bot.bot_alias) ->
        String.trim_leading(text, event.bot.bot_alias)

      true ->
        ""
    end

    case Regex.run(regex, text) do
      nil ->
        state

      matches ->
        matches = Enum.drop(matches, 1)

        if Function.info(cb)[:arity] == 2 do
          cb.(matches, event)
          state
        else
          cb.(matches, event, state)
        end
    end
  end
  def respond(_, _, state, _), do: state

  @doc """
  Defines a listener that will match any regex.
  """
  def hear(%Message{text: text}=event, state, regex, cb) do
    case Regex.run(regex, text) do
      nil ->
        state

      matches ->
        matches = Enum.drop(matches, 1)

        if is_function(cb, 2) do
          cb.(matches, event)
          state
        else
          cb.(matches, event, state)
        end
    end
  end
  def hear(_, _, state, _), do: state

  @doc """
  Defines a generic listener. This listener receives all events and passes them
  to the matcher function. If the matcher function returns a truthy value then the second
  callback will be executed with the value passed as the first argument and the event
  as the second. If the matcher returns false then the callback will be skipped.
  If you need to return a falsey value from your matcher you will need to wrap it
  in another value such as a tuple or a map.

  The callback can either be a 2 arity or 3 arity function with the optional 3rd
  argument being the current state for the handler.
  """
  def listen(event, state, matcher, cb) when is_function(matcher) and is_function(cb) do
    case matcher.(event, state) do
      false ->
        state

      val ->
        if is_function(cb, 2) do
          cb.(val, event)
          state
        else
          cb.(val, event, state)
        end
    end
  end
end
