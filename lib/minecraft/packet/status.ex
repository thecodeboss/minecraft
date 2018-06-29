defmodule Minecraft.Packet.Status do
  @moduledoc """
  Serialization and deserialization routines for status packets.
  """
  alias Minecraft.Packet.Client
  alias Minecraft.Packet.Server
  alias Minecraft.Protocol
  import Minecraft.Packet

  @type packet_id :: 0..1

  @doc """
  Deserializes a status packet.
  """
  @spec deserialize(packet_id, binary, type :: :client | :server) ::
          {packet :: term, new_state :: Protocol.state(), rest :: binary}
  def deserialize(packet_id, data, type \\ :client)

  def deserialize(0 = _packet_id, rest, :client) do
    {%Client.Status.Request{}, :status, rest}
  end

  def deserialize(1 = _packet_id, data, :client) do
    <<payload::64-signed, rest::binary>> = data
    {%Client.Status.Ping{payload: payload}, :status, rest}
  end

  def deserialize(0 = _packet_id, data, :server) do
    {json, rest} = decode_string(data)
    {%Server.Status.Response{json: json}, :status, rest}
  end

  def deserialize(1 = _packet_id, data, :server) do
    <<payload::64-signed, rest::binary>> = data
    {%Server.Status.Pong{payload: payload}, :status, rest}
  end

  @doc """
  Serializes a status packet.
  """
  @spec serialize(packet :: struct) :: binary
  def serialize(packet)

  def serialize(%Client.Status.Request{}) do
    ""
  end

  def serialize(%Client.Status.Ping{payload: payload}) do
    <<payload::64-signed>>
  end

  def serialize(%Server.Status.Response{json: json}) do
    encode_string(json)
  end

  def serialize(%Server.Status.Pong{payload: payload}) do
    <<payload::64-signed>>
  end
end
