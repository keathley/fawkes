defmodule FawkesTest do
  use ExUnit.Case, async: false

  alias Fawkes.Adapter.TestAdapter
  alias Fawkes.TestHandlers

  setup do
    opts = [
      name: TestBot,
      bot_name: "fawkes",
      bot_alias: ".",
      adapter: {TestAdapter, [parent: self()]},
      brain: {Fawkes.Brain.InMemory, []},
      handlers: [
        {TestHandlers.Counter, 0},
        {TestHandlers.Brain, nil},
      ],
    ]
    # {:ok, pid} = Fawkes.start_link(opts)

    start_supervised({Fawkes, opts})

    {:ok, bot: TestBot}
  end

  test "can be started" do
    TestAdapter.chat("inc")
    assert_receive {:say, "incremented count"}

    TestAdapter.chat("count")
    assert_receive {:say, "Count: 1"}
  end

  test "bot can store data in its brain" do
    TestAdapter.chat("set this in that")
    assert_receive {:say, "Ok, I set 'that'"}

    TestAdapter.chat("get that")
    assert_receive {:say, "The value of 'that' is 'this'"}
  end

  test "bot provides help" do
    TestAdapter.chat(".help")
    assert_receive {:code, help}
    assert help == """
    .help - Prints this help message
    count - Returns the count
    inc - Increments the internal counter
    get <key> - Gets the value from the bots brain
    set <value> in <key> - Sets the value in the key in the bot's brain
    """ |> String.trim
  end
end
