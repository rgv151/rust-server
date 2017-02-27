import os, posix, asyncdispatch, websocket, strutils, json

const
  IDENTIFIER = 10002

let
  RCON_PORT = Port parseInt(getEnv("RUST_RCON_PORT"))
  RCON_PASSWORD = getEnv("RUST_RCON_PASSWORD")

  ws = waitFor newAsyncWebsocket("localhost", RCON_PORT, "/" & RCON_PASSWORD, ssl = false)


proc runCommand(cmd: string) {.async.} =
  let cmd = %*{
    "Identifier": IDENTIFIER,
    "Message": cmd,
    "Name": "rconapp"
  }
  await ws.sock.sendText($cmd, true)


for i in 5..1:
  waitFor runCommand("say NOTICE: We're updating the server in <color=orange>" & $i & " minutes</color>, so get to a safe spot!")
  waitFor sleepAsync(1000)

waitFor runCommand("quit")
waitFor ws.close()

if fileExists("/tmp/restart_app.lock"):
  discard unlink("/tmp/restart_app.lock")

discard execShellCmd("kill -s 2 $(pidof bash)")
