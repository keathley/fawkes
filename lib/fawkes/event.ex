defmodule Fawkes.Event do
  @moduledoc """
  Defines all of the event types that Fawkes is aware of as well as common functions
  for responding to events.
  """

  @type t :: term()

  defmodule Message do
    defstruct [
      bot: nil,
      id: nil,
      text: "",
      user: %{id: nil, real_name: nil},
      app: %{id: nil, bot_id: nil, name: nil},
      channel: %{id: nil, name: nil},
      mentions: [],
      attachments: [],
    ]
  end

  defmodule ReactionAdded do
    defstruct [
      bot: nil,
      id: nil,
      item_id: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, real_name: nil},
      reaction: nil,
    ]
  end

  defmodule ReactionRemoved do
    defstruct [
      bot: nil,
      id: nil,
      item_id: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, real_name: nil},
      reaction: nil,
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
      user: %{id: nil, real_name: nil},
    ]
  end

  defmodule ChannelLeft do
    defstruct [
      bot: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, real_name: nil},
    ]
  end
end
