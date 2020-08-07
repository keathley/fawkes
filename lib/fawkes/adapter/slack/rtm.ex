defmodule Fawkes.Adapter.Slack.RTM do
  @moduledoc false
  @behaviour :websocket_client

  alias Fawkes.HTTPClient
  alias Fawkes.EventProducer
  alias Fawkes.Event.{
    Message,
    ReactionAdded,
    ReactionRemoved,
    ChannelJoined,
    ChannelLeft,
  }

  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
    }
  end

  def start_link(opts) do
    {:ok, data} = get_rtm_url(opts[:token])

    data =
      data
      |> Map.put(:token, opts[:token])
      |> Map.put(:producer, opts[:producer])
      |> Map.put(:cache, opts[:cache])

    {:ok, pid} = :websocket_client.start_link(data.url, __MODULE__, data, keepalive: 10_000)
    Process.register(pid, opts[:name])
    {:ok, pid}
  end

  def send_message(name, channel, text) do
    pid = Process.whereis(name)
    json = %{
      type: "message",
      text: text,
      channel: channel,
    }
    json = Jason.encode!(json)
    :websocket_client.cast(pid, {:text, json})
  end

  def init(state) do
    {:reconnect, state}
  end

  def onconnect(_, state) do
    Logger.debug "Connected as #{state.bot.name}"
    EventProducer.set_bot_name(state.producer, "@#{state.bot.id}")
    {:ok, state}
  end

  def ondisconnect(reason, state) do
    case reason do
      {:error, :keepalive_timeout} ->
        {:reconnect, state}

      _ ->
        {:close, reason, state}
    end
  end

  def websocket_handle({:text, message}, _, state) do
    message = prepare_message(message)
    event = build_event(message, state)

    unless event == nil do
      Fawkes.EventProducer.notify(state.producer, event)
    end

    {:ok, state}
  end

  def websocket_handle(_, _, state), do: {:ok, state}

  def websocket_info(_message, _conn, state) do
    {:ok, state}
  end

  def websocket_terminate(_reason, _conn, _state) do
    :ok
  end

  defp prepare_message(binstring) do
    binstring
    |> :binary.split(<<0>>)
    |> List.first()
    |> Jason.decode!()
  end

  defp build_event(%{"type" => "message"}=event, state) do
    user        = get_user(event["user"], state)
    app         = get_app(event["bot_profile"])
    channel     = get_channel(event["channel"], state)
    attachments = get_attachments(event["attachments"])

    %Message{
      bot: self(),
      id: event["ts"],
      text: replace_links(event["text"]),
      user: user,
      app: app,
      channel: channel,
      attachments: attachments,
    }
  end

  defp build_event(%{"type" => "member_joined_channel"}=event, state) do
    user    = get_user(event["user"], state)
    channel = get_channel(event["channel"], state)

    %ChannelJoined{
      bot: self(),
      channel: channel,
      user: user,
    }
  end

  defp build_event(%{"type" => "member_left_channel"}=event, state) do
    user    = get_user(event["user"], state)
    channel = get_channel(event["channel"], state)

    %ChannelLeft{
      bot: self(),
      channel: channel,
      user: user,
    }
  end

  defp build_event(%{"type" => "reaction_added"}=event, state) do
    user    = get_user(event["user"], state)
    channel = get_channel(get_in(event, ["item", "channel"]), state)

    %ReactionAdded{
      bot: self(),
      id: event["ts"],
      item_id: event["item"]["ts"],
      channel: channel,
      user: user,
      reaction: event["reaction"],
    }
  end

  defp build_event(%{"type" => "reaction_removed"}=event, state) do
    user    = get_user(event["user"], state)
    channel = get_channel(get_in(event, ["item", "channel"]), state)

    %ReactionRemoved{
      bot: self(),
      id: event["ts"],
      item_id: event["item"]["ts"],
      channel: channel,
      user: user,
      reaction: event["reaction"]
    }
  end

  defp build_event(_event, _state), do: nil

  def get_rtm_url(token) do
    request = Finch.build(:get, "https://slack.com/api/rtm.connect?token=#{token}&batch_presence_aware=true&presence_sub=false")
    with {:ok, resp} <- Finch.request(request, HTTPClient),
         {:ok, json} <- Jason.decode(resp.body) do
      case json do
        %{"ok" => true} ->
          data = %{
            bot: %{
              id: get_in(json, ["self", "id"]),
              name: get_in(json, ["self", "name"]),
            },
            team: %{
              id: get_in(json, ["team", "id"]),
              domain: get_in(json, ["team", "domain"]),
              name: get_in(json, ["team", "name"]),
            },
            url: json["url"]
          }

          {:ok, data}

        %{"error" => error} ->
          {:error, error}
      end
    end
  end

  defp get_channel(channel, state) do
    Mentat.fetch(state.cache, channel, [ttl: 60_000], fn _ ->
      request = Finch.build(:get, slack_host() <> "conversations.info?channel=#{channel}&token=#{state.token}")

      with {:ok, resp} <- Finch.request(request, HTTPClient),
           {:ok, %{"ok" => true, "channel" => json}} <- Jason.decode(resp.body) do
        channel = %{id: json["id"], name: json["name"]}
        {:commit, channel}
      else
        _error -> {:ignore, %{id: channel, name: nil}}
      end
    end)
  end

  defp get_user(user, state) do
    Mentat.fetch(state.cache, user, [ttl: 60_000], fn _ ->
      request = Finch.build(:get, slack_host() <> "users.info?user=#{user}&token=#{state.token}")

      with {:ok, resp} <- Finch.request(request, HTTPClient),
           {:ok, %{"ok" => true, "user" => json}} <- Jason.decode(resp.body) do
        user = %{id: json["id"], name: json["name"], real_name: json["real_name"]}
        {:commit, user}
      else
        _error -> {:ignore, %{id: user, name: nil, real_name: nil}}
      end
    end)
  end

  defp get_app(bot_profile) do
    %{
      id: get_in(bot_profile, ["app_id"]),
      bot_id: get_in(bot_profile, ["id"]),
      name: get_in(bot_profile, ["name"]),
    }
  end

  defp get_attachments(attachments) when is_list(attachments) do
    attachments
    |> Enum.map(&get_attachment/1)
  end
  defp get_attachments(_), do: []

  def get_attachment(attachment) do
    fields = get_fields(get_in(attachment, ["fields"]))

    %{
      pretext: get_in(attachment, ["pretext"]),
      author_name: get_in(attachment, ["author_name"]),
      title: get_in(attachment, ["title"]),
      text: get_in(attachment, ["text"]),
      fields: fields,
      footer: get_in(attachment, ["footer"]),
    }
  end

  defp get_fields(fields) when is_list(fields) do
    fields
    |> Enum.map(&get_field/1)
  end
  defp get_fields(_), do: []

  defp get_field(field) do
    %{
      title: get_in(field, ["title"]),
      value: get_in(field, ["value"]),
      short: get_in(field, ["short"]),
    }
  end

  defp slack_host do
    "https://slack.com/api/"
  end

  @link_regex ~r/<([^>|]+)>/
  defp replace_links(text) do
    Regex.replace(@link_regex, text, fn _, link -> link end)
  end
end
