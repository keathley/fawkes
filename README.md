# Fawkes

Docs: [https://hexdocs.pm/fawkes](https://hexdocs.pm/fawkes).

<!-- MDOC !-->

Fawkes is a system for building chatbots.

## Starting a bot

Fawkes provides an interface that you can use to start a new bot in your
applications supervision tree.

```elixir
Fawkes.start_link([
  name: MyRobot,
  bot_name: "fawkes",
  bot_alias: ".",
  brain: {Fawkes.Brain.Redis, []},
  adapter: {Slack, [token: "SOME SLACK TOKEN"]},
  handlers: [
    {Echo, nil},
    {Shipit, urls},
  ]
])
```

## Event Handlers

In order for your bot to do useful things you need to define an event hander:

```elixir
defmodule EchoHandler do
  @behaviour Fawkes.EventHandler

  alias Fawkes.Bot
  alias Fawkes.Event.Message

  def init(_opts) do
    {:ok, nil}
  end

  def handle_event(%Message{text: "echo " <> text}=event, state) do
    Bot.say(event, text)
    state
  end
  def handle_event(_, state), do: state
end
```

Your handler can match on any of the events emitted by Fawkes. See the `Event`
module docs for more details.

## Listeners

The `EventHandler` behaviour is the most flexible approach for responding to
events. But its not always the most convenient or use friendly approach. Fawkes
also provides the `Fawkes.Listener` module which makes it easy to build custom
responders.

```elixir
defmodule Fawkes.Handlers.Echo do
  @moduledoc false
  use Fawkes.Listener

  @help """
  fawkes echome <text> - Echos the text back to you
  """
  respond ~r/echome (.*)/, fn [match], event ->
    reply(event, match)
  end

  @help """
  echo <text> - Echos the text back to the channel
  """
  hear ~r/^echo (.*)/, fn [match], event ->
    say(event, match)
  end

  @help """
  echocode <text> - Echos the text back to the channel as code
  """
  hear ~r/^echocode (.*)/, fn [match], event ->
    code(event, match)
  end
end
```

Any handlers defined using the `Fawkes.Listener` api can be added to the
handler list in the same way as other handlers.

## Help command

Fawkes provides a built in "help" handler. This handler gets the list handlers
and uses the `help/0` function defined in each module to create a help message.
Because of this, users are encouraged to write help functions for their
handlers. Each help message should be written on a single line. If you need to
indicate that a listener needs to mention the bot you can write a help message like

```elixir
@help """
fawkes echo <text> - Echo's the text back to you.
"""
respond(~r/echo (.*)/, fn matches, event ->
end)
```

You should always use `"fawkes"` in your help messages. The help handler will
automatically replace this with your bots name or alias.

## Brains

Fawkes provides an interface that handlers can use to persist values. The
default brain is an in memory store. If your bot requires persistence you can
use the built in redis brain or implement your own.

## Architecture and Adapters

The Adapter's job is to process incoming messages and deliver them to Fawkes'
internal `EventProducer`. Internally, Fawkes uses GenStage to broadcast events
to all of the event handlers. Messages from the bot can be sent back to the adapter
using the functions in `Fawkes.Event`. These are delivered to the adapter process
which formats and sends the message based on the conventions of that adapter.

<!-- MDOC !-->

## Installation

```elixir
def deps do
  [
    {:fawkes, "~> 0.2.0"}
  ]
end
```

