defmodule Fawkes.Handlers.Echo do
  @moduledoc false
  @behaviour Fawkes.EventHandler

  alias Fawkes.Event
  alias Fawkes.Event.Message

  def init(_) do
    {:ok, nil}
  end

  def handle_event(%Message{text: "echo " <> text}=event, state) do
    Event.say(event, text)
    state
  end
  def handle_event(%Message{text: "echome " <> text}=event, state) do
    Event.reply(event, text)
    state
  end
  def handle_event(%Message{text: "echohere " <> text}=event, state) do
    Event.message_channel(event, text)
    state
  end
  def handle_event(%Message{text: "echocode " <> text}=event, state) do
    Event.code(event, text)
    state
  end
  def handle_event(_, state), do: state
end
