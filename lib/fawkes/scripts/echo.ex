defmodule Fawkes.Scripts.Echo do
  # use Fawkes.Script

  # respond ~r/hey you/i, fn msg ->
  #   reply msg, "Snake!"
  # end

  # hear ~r/^echo (.*)/, fn %{matches: [match]}=msg ->
  #   say msg, "#{match}"
  # end

  # respond ~r/chagrin/, fn msg ->
  #   say msg, "I am filled with chagrin"
  # end

  # respond ~r/multi/, fn msg ->
  #   say msg, "step 1."
  #   :timer.sleep(1_000)
  #   say msg, "step 2."
  #   :timer.sleep(1_000)
  #   say msg, "step 3."
  # end

  def listeners(bot) do
    Fawkes.Listener.hear ~r/^echo (.*)/i, fn %{matches: [match]}=msg ->
      send(msg.bot, {:say, msg, "#{match}"})
    end

    Fawkes.Listener.respond ~r/hey you/i, fn msg ->
      send(msg.bot, {:reply, msg, "Hey back"})
    end
  end
end
