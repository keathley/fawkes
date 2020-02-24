defmodule Fawkes.Adapter.Slack do
  use Slack

  @behaviour Fawkes.Adapter

  alias Fawkes.Event.{
    Message,
    Mention,
    ReactionAdded,
    ReactionRemoved,
    ChannelJoined,
    ChannelLeft,
  }

  require Logger

  def child_spec(opts) do
    token = opts[:token] || raise ArgumentError, "Requires a slack token"
    producer = opts[:producer] || raise ArgumentError, "Requires a producer"

    %{
      id: __MODULE__,
      start: {Slack.Bot, :start_link, [__MODULE__, [producer: producer], token]},
    }
  end

  def say(event, text) do
    send(event.bot, {:say, event, text})
  end

  def reply(event, text) do
    send(event.bot, {:reply, event, text})
  end

  def code(event, text) do
    send(event.bot, {:code, event, text})
  end

  def message_channel(event, text) do
    send(event.bot, {:message_channel, event, text})
  end

  def handle_connect(slack, state) do
    Logger.debug "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(event, slack, state) do
    event = build_event(event, slack)

    unless event == nil do
      Fawkes.EventProducer.notify(state[:producer], event)
    end

    {:ok, state}
  end
  def handle_event(_event, _, state) do
    {:ok, state}
  end

  def handle_info({:say, msg, text}, slack, state) do
    send_message(text, msg.channel.id, slack)
    {:ok, state}
  end

  def handle_info({:reply, msg, text}, slack, state) do
    text = "<@#{msg.user.id}> #{text}"
    send_message(text, msg.channel.id, slack)
    {:ok, state}
  end

  def handle_info({:code, event, text}, slack, state) do
    text = """
    ```
    #{text}
    ```
    """
    send_message(text, event.channel.id, slack)
    {:ok, state}
  end

  def handle_info({:message_channel, event, text}, slack, state) do
    text = "<!here> #{text}"
    send_message(text, event.channel.id, slack)
    {:ok, state}
  end

  def handle_info(msg, _, state) do
    Logger.debug(fn -> "Unhandled message: #{inspect msg}" end)
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

  defp build_event(event, slack) do
    case event.type do
      "message" ->
        user    = user(event, slack)
        channel = channel(event, slack)
        %Message{
          handler: __MODULE__,
          bot: self(),
          text: event.text,
          user: user,
          channel: channel,
        }

      "reaction_added" ->
        %ReactionAdded{
          handler: __MODULE__,
          bot: self(),
          reaction: event.reaction,
          user: user(event, slack),
          # TODO - Add the other fields here
        }

      "reaction_removed" ->
        %ReactionRemoved{
          handler: __MODULE__,
          bot: self(),
          reaction: event.reaction,
          user: user(event, slack),
          # TODO - Add the other fields here
        }

      _ ->
        nil
    end
  end
end
