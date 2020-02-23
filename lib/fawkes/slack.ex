defmodule Fawkes.Slack do
  use Slack

  alias Fawkes.Message

  require Logger

  def child_spec(opts) do
    token = opts[:token] || raise ArgumentError, "Requires a slack token"

    %{
      id: __MODULE__,
      start: {Slack.Bot, :start_link, [__MODULE__, [], token]},
    }
  end

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    # IO.inspect([message, slack], label: "Slack")
    user    = user(message, slack)
    channel = channel(message, slack)
    msg     = %Message{
      bot: self(),
      text: message.text,
      user: user,
      channel: channel,
      bot_name: "<@#{slack.me.id}>",
      bot_alias: ".", # TODO - Make this configurable
    }

    Fawkes.Listener.handle_message(msg)

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:say, msg, text}, slack, state) do
    send_message(text, msg.channel.id, slack)
    {:ok, state}
  end

  def handle_info({:reply, msg, text}, slack, state) do
    text = "<@#{msg.user.id}> #{text}"
    send_message(text, msg.channel.id, slack)
    {:ok, state}
  end

  def handle_info(msg, _, state) do
    Logger.info(fn -> "Unhandled message: #{msg}" end)
    {:ok, state}
  end

  defp channel(%{channel: id}, slack) do
    case slack.channels[id] do
      nil ->
        %{id: id, name: ""}

      channel ->
        %{id: id, name: channel}
    end
  end

  defp user(%{user: id}, slack) do
    # We don't guard here because we should never get a message from a user we
    # don't know.
    user = slack.users[id]

    name = case user.profile.display_name do
      "" -> user.name
      name -> name
    end

    %{
      id: id,
      name: name
    }
  end
end
