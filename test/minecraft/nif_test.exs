defmodule Minecraft.NIFTest do
  use ExUnit.Case, async: true

  setup_all do
    :ok = Minecraft.NIF.set_random_seed(123)
    :ok
  end

  test "Generating chunks works" do
    assert {:ok, _chunk} = Minecraft.NIF.generate_chunk(-10, 53)
  end
end
