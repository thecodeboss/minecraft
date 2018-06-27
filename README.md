# Minecraft

A Minecraft server implementation in Elixir. Until this reaches vestion 1.0, please do not consider it ready for running real Minecraft servers (unless you're adventurous).

## Minecraft Protocol

The Minecraft Protocol is documented in [the Minecraft wiki](https://minecraft.gamepedia.com/Classic_server_protocoli).

## To-do

### General

- [ ] Heartbeat
- [ ] User Authentication
- [ ] World Generation
- [ ] World in-memory storage
- [ ] World persistence on disk
- [ ] Core server logic (this is a catch-all)

### Client-server packets

- [ ] Player Identification
- [ ] Set Block
- [ ] Position and Orientation
- [ ] Message

### Server-client packets

- [ ] Server identification
- [ ] Ping
- [ ] Level Initialize
- [ ] Level Data Chunk
- [ ] Level Finalize
- [ ] Set Block
- [ ] Spawn Player
- [ ] *(optional)* Position and Orientation (player teleport)
- [ ] *(optional)* Position and Orientation update
- [ ] *(optional)* Position update
- [ ] *(optional)* Orientation update
- [ ] Despawn player
- [ ] Message
- [ ] Disconnect player
- [ ] Update user type
