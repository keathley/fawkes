defmodule Fawkes.Adapter.Slack do
  use Slack

  @behaviour Fawkes.Adapter

  alias Slack.Web.{Users, Channels}
  alias Fawkes.EventProducer
  alias Fawkes.Event.{
    Message,
    ReactionAdded,
    ReactionRemoved,
    # ChannelJoined,
    # ChannelLeft,
  }

  require Logger

  def child_spec(opts) do
    token = opts[:token] || raise ArgumentError, "Requires a slack token"
    producer = opts[:producer] || raise ArgumentError, "Requires a producer"
    slack_opts = Map.new(opts[:adapter_options])

    args = [
      __MODULE__, # The callback module to use,
      [producer: producer], # Initial arguments
      token, # Slack API Token
      slack_opts, # Name and other options. We need this so we can find our adapter later.
    ]

    %{
      id: __MODULE__,
      start: {Slack.Bot, :start_link, args},
    }
  end

  def say(event, text) do
    message_adapter(event, {:say, event, text})
  end

  def reply(event, text) do
    message_adapter(event, {:reply, event, text})
  end

  def code(event, text) do
    message_adapter(event, {:code, event, text})
  end

  defp message_adapter(event, msg) do
    send(Process.whereis(event.bot.adapter_name), msg)
  end

  def handle_connect(slack, state) do
    state =
      state
      |> Map.new()
      |> Map.put(:token, slack.token)
      |> Map.put(:users, %{})
      |> Map.put(:channels, %{})

    Logger.debug "Connected as #{slack.me.name}"
    EventProducer.set_bot_name(state[:producer], "@#{slack.me.id}")
    {:ok, state}
  end

  def handle_event(event, _slack, state) do
    {event, state} = build_event(event, state)

    unless event == nil do
      Fawkes.EventProducer.notify(state.producer, event)
    end

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

  defp build_event(event, state) do
    case event.type do
      "message" ->
        {channel, state} = get_channel(event.channel, state)
        {user, state} = get_user(event.user, state)

        event = %Message{
          bot: self(),
          text: replace_links(event.text),
          user: user,
          channel: channel,
        }
        {event, state}

      "reaction_added" ->
        {user, state} = get_user(event.user, state)
        event = %ReactionAdded{
          bot: self(),
          reaction: event.reaction,
          user: user,
          # TODO - Add the other fields here
        }
        {event, state}

      "reaction_removed" ->
        {user, state} = get_user(event.user, state)
        event = %ReactionRemoved{
          bot: self(),
          reaction: event.reaction,
          user: user,
          # TODO - Add the other fields here
        }
        {event, state}

      _ ->
        {nil, state}
    end
  end

  def get_channel(id, state) do
    case state.channels[id] do
      nil ->
        info = Channels.info(id, %{token: state.token})
        channel = %{id: id, name: get_in(info, ["channel", "name"])}
        {channel, put_in(state, [:channels, id], channel)}

      channel ->
        {channel, state}
    end
  end

  def get_user(id, state) do
    case state.users[id] do
      nil ->
        info = Users.info(id, %{token: state.token})
        user = %{id: id, real_name: get_in(info, ["user", "real_name"])}
        {user, put_in(state, [:users, id], user)}

      user ->
        {user, state}
    end
  end


  @link_regex ~r/<([^>|]+)>/
  defp replace_links(text) do
    Regex.replace(@link_regex, text, fn _, link -> link end)
  end
end
