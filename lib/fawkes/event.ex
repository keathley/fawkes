defmodule Fawkes.Event do
  @moduledoc """
  Defines all of the event types that Fawkes is aware of as well as common functions
  for responding to events.
  """

  @type t :: term()

  defmodule Message do
    defstruct [
      bot: nil,
      text: "",
      user: %{id: nil, name: nil},
      channel: %{id: nil, name: nil},
      mentions: [],
    ]
  end

  defmodule ReactionAdded do
    defstruct [
      bot: nil,
      user: %{id: nil, name: nil},
      reaction: nil,
      item: %{channel_id: nil, ts: nil, type: nil},
      item_user: "",
    ]
  end

  defmodule ReactionRemoved do
    defstruct [
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
      bot: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, name: nil},
    ]
  end

  defmodule ChannelLeft do
    defstruct [
      bot: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, name: nil},
    ]
  end
end
