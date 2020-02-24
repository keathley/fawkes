defmodule Fawkes.Event do
  @moduledoc """
  Defines all of the event types that Fawkes is aware of as well as common functions
  for responding to events.
  """

  @type t :: term()

  @doc """
  Sends a text message back to the channel the event originated from.
  """
  def say(event, text) do
    event.handler.say(event, text)
  end

  @doc """
  Mentions the user who created the event with the specified text.
  """
  def reply(event, text) do
    event.handler.reply(event, text)
  end

  @doc """
  Sends a message to the event's channel, formatted as a code snippet.
  """
  def code(event, text) do
    event.handler.code(event, text)
  end

  @doc """
  Message everyone in the event's channel. This is typically equivalent to an
  `@here` message.
  """
  def message_channel(event, text) do
    event.handler.message_channel(event, text)
  end

  defmodule Message do
    defstruct [
      handler: nil,
      bot: nil,
      text: "",
      user: %{id: nil, name: nil},
      channel: %{id: nil, name: nil},
      mentions: [],
    ]
  end

  defmodule ReactionAdded do
    defstruct [
      handler: nil,
      bot: nil,
      user: %{id: nil, name: nil},
      reaction: nil,
      item: %{channel_id: nil, ts: nil, type: nil},
      item_user: "",
    ]
  end

  defmodule ReactionRemoved do
    defstruct [
      handler: nil,
      bot: nil,
      user: %{id: nil, name: nil},
      reaction: nil,
      item_user: nil,
      item: %{channel_id: nil, ts: nil, type: nil},
    ]
  end

  defmodule TopicChanged do
    # Our slack adapter can't currently grab this yet.
    defstruct [channel: %{id: nil, name: nil}]
  end

  defmodule ChannelJoined do
    defstruct [
      channel: %{id: nil, name: nil},
      user: %{id: nil, name: nil},
    ]
  end

  defmodule ChannelLeft do
    defstruct [
      channel: %{id: nil, name: nil},
      user: %{id: nil, name: nil},
    ]
  end
end
