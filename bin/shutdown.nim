import os, posix, asyncdispatch, websocket, strutils, json

const
  IDENTIFIER = 10003

let
  RCON_PORT = Port parseInt(getEnv("RUST_RCON_PORT"))
  RCON_PASSWORD = getEnv("RUST_RCON_PASSWORD")

  ws = waitFor newAsyncWebsocket("localhost", RCON_PORT, "/" & RCON_PASSWORD, ssl = false)


let cmd = %*{
  "Identifier": IDENTIFIER,
  "Message": "quit",
  "Name": "rconapp"
}
waitFor ws.sock.sendText($cmd, true)
waitFor ws.close()
