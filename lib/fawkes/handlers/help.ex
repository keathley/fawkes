defmodule Fawkes.Handlers.Help do
  @moduledoc """
  A handler for surfacing help messages about your bots handlers.
  This handler is added automatically to your bot and you do not need to add
  it yourself. This documentation is only here for posterity.
  """
  use Fawkes.Listener

  def init(bot, handlers) do
    message =
      handlers
      |> Enum.map(& &1.help())
      |> Enum.flat_map(& String.split(&1, "\n"))
      |> Enum.map(&String.trim(&1))
      |> Enum.reject(& &1 == "")
      |> Enum.map(& String.replace(&1, ~r/^fawkes /, bot.bot_alias || "name"))
      |> Enum.join("\n")

    {:ok, message}
  end

  @help """
  fawkes help - Prints this help message
  """
  respond(~r/help/, fn _, event, help_msg ->
    code(event, help_msg)

    help_msg
  end)
end
