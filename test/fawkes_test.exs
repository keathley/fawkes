defmodule FawkesTest do
  use ExUnit.Case, async: false

  defmodule TestHandler do
    use Fawkes.Listener

    alias Fawkes.Bot

    hear ~r/inc/, fn _matches, _event, {count, parent} ->
      send(parent, :inced)
      {count + 1, parent}
    end

    hear ~r/count/, fn _matches, _msg, {count, parent} ->
      send(parent, {:count, count})
      {count, parent}
    end

    hear ~r/set (.*) in (.*)/, fn matches, event, {count, parent} ->
      [value, key] = matches

      result = Fawkes.Bot.set(event, key, value)
      send(parent, {:set, result})

      {count, parent}
    end

    hear ~r/get (.*)/, fn matches, msg, {count, parent} ->
      val = Bot.get(msg, Enum.at(matches, 0))
      send(parent, {:get, val})
      {count, parent}
    end
  end

  defmodule TestAdapter do
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    end

    def msg(text) do
      GenServer.call(__MODULE__, {:msg, text})
    end

    def init(state) do
      {:ok, Map.new(state)}
    end

    def handle_call({:msg, text}, _from, state) do
      Fawkes.EventProducer.notify(state.producer, %Fawkes.Event.Message{text: text})

      {:reply, :ok, state}
    end
  end

  setup do
    opts = [
      name: TestBot,
      adapter: {TestAdapter, []},
      brain: {Fawkes.Brain.InMemory, []},
      handlers: [
        {TestHandler, {0, self()}},
      ],
    ]
    {:ok, pid} = Fawkes.start_link(opts)

    on_exit fn ->
      Process.exit(pid, :brutal_kill)
    end

    {:ok, bot: TestBot}
  end

  test "can be started", %{bot: bot} do
    TestAdapter.msg("inc")
    assert_receive :inced

    TestAdapter.msg("count")
    assert_receive {:count, 1}
  end

  test "bot can store data in its brain", %{bot: bot} do
    TestAdapter.msg("set this in that")
    assert_receive {:set, :ok}

    TestAdapter.msg("get that")
    assert_receive {:get, "this"}
  end
end
