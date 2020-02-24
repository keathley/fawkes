defmodule Fawkes.Adapter.Slack do
  use Slack

  alias Fawkes.Event.{
    Message,
    ReactionAdded,
    ReactionRemoved,
    ChannelJoined,
    ChannelLeft,
  }

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

  def handle_event(event, slack, state) do
    event = build_event(event, slack)

    unless event == nil do
      Fawkes.EventProducer.notify(Fawkes.EventProducer, event)
    end

    {:ok, state}
  end
  def handle_event(_event, _, state) do
    {:ok, state}
  end

  defp build_event(event, slack) do
    case event.type do
      "message" ->
        user    = user(event, slack)
        channel = channel(event, slack)
        %Message{
          bot: self(),
          text: event.text,
          user: user,
          channel: channel,
        # bot_name: "<@#{slack.me.id}>",
        # bot_alias: ".", # TODO - Make this configurable
        }

      "reaction_added" ->
        %ReactionAdded{
          bot: self(),
          reaction: event.reaction,
          user: user(event, slack),
          # TODO - Add the other fields here
        }

      "reaction_removed" ->
        %ReactionAdded{
          bot: self(),
          reaction: event.reaction,
          user: user(event, slack),
          # TODO - Add the other fields here
        }

      _ ->
        nil
    end
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
