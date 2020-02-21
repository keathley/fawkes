defmodule FawkesTest do
  use ExUnit.Case
  doctest Fawkes

  test "greets the world" do
    assert Fawkes.hello() == :world
  end
end
