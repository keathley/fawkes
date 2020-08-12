defmodule Fawkes.Event do
  @moduledoc """
  Defines all of the event types that Fawkes is aware of as well as common functions
  for responding to events.
  """

  @type t :: term()

  defmodule Message do
    @moduledoc false
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
    @moduledoc false
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
    @moduledoc false
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
    @moduledoc false
    defstruct [channel: %{id: nil, name: nil}]
  end

  defmodule ChannelJoined do
    @moduledoc false
    defstruct [
      bot: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, real_name: nil},
    ]
  end

  defmodule ChannelLeft do
    @moduledoc false
    defstruct [
      bot: nil,
      channel: %{id: nil, name: nil},
      user: %{id: nil, real_name: nil},
    ]
  end
end
