# Minecraft

[![Build Status](https://travis-ci.com/thecodeboss/minecraft.svg?branch=master)](https://travis-ci.com/thecodeboss/minecraft)
[![Inline docs](http://inch-ci.org/github/thecodeboss/minecraft.svg)](http://inch-ci.org/github/thecodeboss/minecraft)
[![Coverage Status](https://coveralls.io/repos/thecodeboss/minecraft/badge.svg?branch=master&service=github)](https://coveralls.io/github/thecodeboss/minecraft?branch=master)
[![Hex.pm version](https://img.shields.io/hexpm/v/minecraft.svg?style=flat-square)](https://hex.pm/packages/minecraft)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/minecraft.svg?style=flat-square)](https://hex.pm/packages/minecraft)
[![License](https://img.shields.io/hexpm/l/minecraft.svg?style=flat-square)](https://hex.pm/packages/minecraft)

A Minecraft server implementation in Elixir. Until this reaches version 1.0, please do not consider it ready for running real Minecraft servers (unless you're adventurous).

You can view [the documentation on Hex](https://hexdocs.pm/minecraft/).

## Minecraft Protocol

The Minecraft Protocol is documented on [wiki.vg](http://wiki.vg/Protocol). The current goal is to support version (1.12.2, protocol 340).

## To-do

The following list of to-do items should be enough to be able to play on the server, at least to the most basic extent.

### General

- [ ] World Generation
- [ ] World in-memory storage
- [ ] World persistence on disk
- [ ] Core server logic (this is a catch-all)

### Handshake Packets

- [x] Client: Handshake

### Status Packets

- [x] Client: Request
- [x] Server: Response
- [x] Client: Ping
- [x] Server: Pong

### Login Packets

- [ ] Client: Login Start
- [ ] Server: Encryption Request
- [ ] Client: Encryption Response
- [ ] *(optional)* Server: Set Compression
- [ ] Server: Login Success
- [ ] Server: Disconnect

### Play Packets

- [ ] Server: Join Game
- [ ] Server: Spawn Position
- [ ] Server: Player Abilities
- [ ] Client: Client Settings
- [ ] Server: Player Position and Look
- [ ] Client: Teleport Confirm
- [ ] Client: Player Position and Look
- [ ] Client: Client Status
- [ ] Server: Window Items
- [ ] Server: Chunk Data
- [ ] Client: Player
- [ ] Client: Player Position
- [ ] Client: Player Look
