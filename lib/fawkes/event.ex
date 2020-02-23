defmodule Fawkes.Event do
  # Mention - Maybe this is just a part of message?
  # Message
  # Reaction
  # Enter Room
  # Leave Room
  # Topic Change

  defmodule Message do
    defstruct [
      bot: nil,
      text: "",
      user: %{id: nil, name: nil},
      channel: %{id: nil, name: nil},
      # matches: [],
      # bot_name: nil,
      # bot_alias: nil,
    ]
  end

  defmodule Mention do
    defstruct [
      bot: nil,
      text: "",
      user: %{id: nil, name: nil},
      channel: %{id: nil, name: nil},
    ]
  end

  defmodule Reaction do
    defstruct [
      bot: nil,
      user: %{id: nil, name: nil},
      message_creator: %{id: nil, name: nil},
      reaction: nil, # Name of the reaction
      item: %{
        type: nil,
        channel: %{id: nil, name: nil},
      },
    ]
  end
end
