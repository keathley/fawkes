defmodule Fawkes.Event do
  @moduledoc """
  Defines all of the event types that Fawkes is aware of.
  """

  @type t :: term()

  def say(event, text) do
    event.handler.say(event, text)
  end

  def reply(event, text) do
    event.handler.reply(event, text)
  end

  def code(event, text) do
    event.handler.code(event, text)
  end

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
