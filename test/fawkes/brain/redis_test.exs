defmodule Fawkes.Brain.RedisTest do
  use ExUnit.Case, async: false

  alias Fawkes.Brain.Redis

  test "stores and retrieves complex values" do
    {:ok, brain} = Redis.start_link(name: TestBrain)
    assert :ok = Redis.set(brain, "complex", %{set: MapSet.new([1,2,3])})
    assert Redis.get(brain, "complex") == %{set: MapSet.new([1,2,3])}
  end

  test "can be started as part of a bot" do
    {:ok, _bot} = Fawkes.start_link([
      name: BrainTestBot,
      adapter: {Fawkes.Adapter.TestAdapter, []},
      brain: {Redis, [host: "localhost", port: 6379]},
    ])
    brain = BrainTestBot.Brain

    assert :ok = Redis.set(brain, "complex", %{set: MapSet.new([1,2,3])})
    assert Redis.get(brain, "complex") == %{set: MapSet.new([1,2,3])}
  end
end
