defmodule Fawkes.Scripts.Echo do
  use Fawkes.Script

  hear ~r/badger/i, fn _msg ->
    "Snake!"
  end

  respond ~r/echo (.*)/, fn %{matches: [match]} ->
    IO.puts "I got some stuff"
    "#{match}"
  end
end
