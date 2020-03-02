defmodule Fawkes.BotTest do
  use ExUnit.Case, async: false

  alias Fawkes.Bot
  alias Fawkes.Event.Message

  describe "listen/4" do
    test "returns the matched value to the callback" do
      us = self()

      Bot.listen(%Message{text: "foo"}, nil,
        fn event, _state ->
          if event.text == "foo" do
            :foo
          else
            false
          end
        end,
        fn foo, event, state ->
          send(us, {:listen, foo, event, state})
        end
      )

      assert_receive {:listen, :foo, msg, nil}
      assert match?(%Message{text: "foo"}, msg)
    end
  end
end
