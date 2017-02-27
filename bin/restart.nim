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


proc main() {.async.} =
  for i in countdown(5, 1):
    await runCommand("say NOTICE: We're updating the server in <color=orange>" & $i & " minutes</color>, so get to a safe spot!")
    await sleepAsync(60000)

  await runCommand("quit")
  await ws.close()

  if fileExists("/tmp/restart_app.lock"):
    discard unlink("/tmp/restart_app.lock")

  discard execShellCmd("kill -s 2 $(pidof bash)")
  quit()

asyncCheck main()
runForever()
