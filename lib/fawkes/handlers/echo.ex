defmodule Fawkes.Handlers.Echo do
  @moduledoc false
  use Fawkes.Listener

  alias Fawkes.Bot

  respond ~r/echome (.*)/, fn [match], event ->
    reply(event, match)
  end

  hear ~r/^echo (.*)/, fn [match], event ->
    say(event, match)
  end

  hear ~r/^echocode (.*)/, fn [match], event ->
    code(event, match)
  end
end
