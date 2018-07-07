defmodule Minecraft.World.NIFTest do
  use ExUnit.Case, async: true

  setup_all do
    :ok = Minecraft.World.NIF.set_random_seed(123)
    :ok
  end

  test "Generating chunks works" do
    assert {:ok, _chunk} = Minecraft.World.NIF.generate_chunk(-10, 53)
  end
end
