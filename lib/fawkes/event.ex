defmodule Fawkes.Event do
  defmodule Message do
    defstruct [
      bot: nil,
      text: "",
      user: %{id: nil, name: nil},
      channel: %{id: nil, name: nil},
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

  defmodule ReactionAdded do
    # Non-message Event: %{
    # event_ts: "1582507206.000800",
    # item: %{channel: "DUB4B6UD6", ts: "1582507199.000700", type: "message"},
    # item_user: "U9XRNQFEK",
    # reaction: "+1",
    # ts: "1582507206.000800",
    # type: "reaction_added",
    # user: "U9XRNQFEK"
# }
    defstruct [
      bot: nil,
      user: %{id: nil, name: nil},
      reaction: nil,
      item: %{channel_id: nil, ts: nil, type: nil},
      item_user: "",
    ]
  end

  defmodule ReactionRemoved do
    # Non-message Event: %{
  # event_ts: "1582507256.000900",
  # item: %{channel: "DUB4B6UD6", ts: "1582507199.000700", type: "message"},
  # item_user: "U9XRNQFEK",
  # reaction: "+1",
  # ts: "1582507256.000900",
  # type: "reaction_removed",
  # user: "U9XRNQFEK"
# }
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
    defstruct [ts: nil]
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
