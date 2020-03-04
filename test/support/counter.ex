defmodule Fawkes.TestHandlers.Counter do
  @moduledoc false
  use Fawkes.Listener

  @help """
  inc - Increments the internal counter
  """
  hear ~r/inc/, fn _matches, event, count ->
    say(event, "incremented count")
    count + 1
  end

  @help """
  count - Returns the count
  """
  hear ~r/count/, fn _matches, event, count ->
    say(event, "Count: #{count}")
    count
  end
end
