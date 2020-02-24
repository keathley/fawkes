defmodule FawkesTest do
  use ExUnit.Case

  defmodule TestHandler do
    @behaviour Fawkes.EventHandler

    def init({count, parent}) do
      {:ok, {count, parent}}
    end

    def handle_event(_event, {count, parent}) do
      send(parent, {:count, count})
      count + 1
    end
  end

  defmodule TestAdapter do
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    def init(state) do
      {:ok, state}
    end

    def handle_call({:notify, text}, _from, state) do
      Fawkes.EventProducer.notify(%Fawkes.Event.Message{text: text})
    end
  end

  test "can be started" do
    handlers = [
      {TestHandler, 0},
    ]
    :ok = Fawkes.start_link([name: MyFawkes, handlers: handlers, adapter: TestAdapter])
    TestAdapter.msg("Some text")

    assert_receive {:count, 0}
  end
end
