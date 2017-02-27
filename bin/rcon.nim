import os, asyncdispatch, websocket, strutils, json

if paramCount() <= 0:
  quit("Error: Please specify an RCON command")

const
  IDENTIFIER = 10001

let
  RCON_PORT = Port parseInt(getEnv("RUST_RCON_PORT"))
  RCON_PASSWORD = getEnv("RUST_RCON_PASSWORD")

  ws = waitFor newAsyncWebsocket("localhost", RCON_PORT, "/" & RCON_PASSWORD, ssl = false)


proc readRcon() {.async.} =
  while true:
    let read = await ws.sock.readData(true)
    if read.opcode == OpCode.Text:
      let data = parseJson(read.data)
      if getNum(data["Identifier"]) == IDENTIFIER:
        echo getStr(data["Message"])
        await ws.close()
        quit()

proc runCommand() {.async.} =

  let cmd = %*{
    "Identifier": IDENTIFIER,
    "Message": join(commandLineParams(), " "),
    "Name": "rconapp"
  }
  await ws.sock.sendText($cmd, true)

asyncCheck readRcon()
asyncCheck runCommand()
runForever()
