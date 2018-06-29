defmodule Minecraft.Packet.Client.Handshake do
  @moduledoc false
  defstruct packet_id: 0,
            protocol_version: 340,
            server_addr: nil,
            server_port: nil,
            next_state: nil
end
