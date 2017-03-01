#!/bin/bash

apt install -y git
cd /tmp
wget -q https://nim-lang.org/download/nim-0.16.0.tar.xz
tar -xJf nim-*
cd nim-*
sh build.sh

PATH="$PATH:/tmp/nim-0.16.0/bin"

nim c koch

./koch nimble

nimble -y install https://github.com/rgv151/websocket.nim.git


cd /tmp/bin
for i in *.nim;do
    nim c -d:release $i
done

mv rcon /usr/bin/
mv restart /usr/bin/restart_app
mv shutdown /usr/bin/shutdown_app

apt remove -y --purge git && apt autoremove -y --purge

rm -rf /tmp/nim* && rm -rf /root/.nimble && rm -rf /tmp/bin
