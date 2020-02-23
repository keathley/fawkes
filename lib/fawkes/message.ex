defmodule Fawkes.Message do
  defstruct [
    bot: nil,
    text: "",
    user: %{},
    channel: %{},
    matches: [],
    bot_name: nil,
    bot_alias: nil,
  ]
end
