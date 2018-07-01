defmodule Minecraft.CryptoTest do
  use ExUnit.Case, async: true

  test "Stopping crypto module deletes temp dir" do
    {:ok, pid} = GenServer.start_link(Minecraft.Crypto, [])
    keys_dir = GenServer.call(pid, :get_keys_dir)
    assert {:ok, _} = File.stat(keys_dir)
    :ok = GenServer.stop(pid)
    assert {:error, _} = File.stat(keys_dir)
  end
end
