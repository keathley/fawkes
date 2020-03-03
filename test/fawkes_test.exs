defmodule FawkesTest do
  use ExUnit.Case, async: false

  alias Fawkes.Adapter.TestAdapter

  defmodule TestHandler do
    use Fawkes.Listener

    hear ~r/inc/, fn _matches, event, count ->
      say(event, "incremented count")
      count + 1
    end

    hear ~r/count/, fn _matches, event, count ->
      say(event, "Count: #{count}")
      count
    end

    hear ~r/set (.*) in (.*)/, fn [value, key], event ->
      result = Fawkes.Bot.set(event.bot, key, value)
      if result == :ok do
        say(event, "Ok, I set '#{key}'")
      else
        say(event, "Something went wrong")
      end
    end

    hear ~r/get (.*)/, fn [key], event ->
      {:ok, val} = Fawkes.Bot.get(event.bot, key)
      say(event, "The value of '#{key}' is '#{val}'")
    end
  end

  setup do
    opts = [
      name: TestBot,
      adapter: {TestAdapter, [parent: self()]},
      brain: {Fawkes.Brain.InMemory, []},
      handlers: [
        {TestHandler, 0},
      ],
    ]
    {:ok, pid} = Fawkes.start_link(opts)

    on_exit fn ->
      Process.exit(pid, :brutal_kill)
    end

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
    flunk "Not tested yet"
  end
end
