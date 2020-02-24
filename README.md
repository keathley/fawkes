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

  alias Fawkes.Event
  alias Fawkes.Event.Message

  def init(_opts) do
    {:ok, nil}
  end

  def handle_event(%Message{text: "echo " <> text}=event, state) do
    Event.say(event, text)
    state
  end
  def handle_event(_, state), do: state
end
```

Your handler can match on any of the events emitted by Fawkes. See the `Event`
module docs for more details.

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
    {:fawkes, "~> 0.1.0"}
  ]
end
```

