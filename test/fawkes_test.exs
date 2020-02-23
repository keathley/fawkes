defmodule FawkesTest do
  use ExUnit.Case

  defmodule TestHandler do
    @behaviour Fawkes.EventHandler

    def init({count, parent}) do
      {:ok, {count, parent}}
    end

    def handle_event(_event, {count, parent}) do
      send(parent, {:count, count})
      {count + 1, parent}
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

  test "can be started" do
    opts = [
      name: TestFawkes,
      adapter: {TestAdapter, []},
      handlers: [
        {TestHandler, {0, self()}},
      ],
    ]
    {:ok, _pid} = Fawkes.start_link(opts)

    TestAdapter.msg("Some text")
    assert_receive {:count, 0}

    TestAdapter.msg("Some text")
    assert_receive {:count, 1}
  end
end
