FROM ubuntu:16.04

MAINTAINER didstopia

# Setup the locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Fixes apt-get warnings
ENV DEBIAN_FRONTEND noninteractive

# Run a quick apt-get update/upgrade
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y --purge

# Install dependencies, mainly for SteamCMD
RUN apt-get install -y \
    ca-certificates \
    software-properties-common \
    python-software-properties \
    lib32gcc1 \
    libstdc++6 \
    curl \
    wget \
    bsdtar \
    build-essential \
    expect \
    libgdiplus

# Run as root
USER root

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/rust
VOLUME ["/steamcmd/rust"]


# Add compile tools
ADD bin /tmp/bin/
RUN cd /tmp && wget https://nim-lang.org/download/nim-0.16.0.tar.xz && tar -xJf nim-* && cd nim-* && sh build.sh && ./bin/nim c koch && ./koch nimble && ./bin/nimble install websocket

WORKDIR /tmp/bin
RUN for i in *.nim;do /tmp/nim/bin/nim c -d:release $i;done && mv rcon /usr/local/ && mv restart /usr/local/bin/restart_app && mv shutdown /usr/local/bin/shutdown_app

WORKDIR /

# Cleanup
RUN rm -rf /tmp/nim && rm -rf /root/.nimble && rm -rf /tmp/bin

# Add the steamcmd installation script
ADD install.txt /install.txt

# Copy the Rust startup script
ADD start_rust.sh /start.sh

# Copy the Rust update check script
ADD update_check.sh /update_check.sh

# Setup cronjob for update checker
ADD crontab /etc/cron.d/update-check
RUN chmod 0644 /etc/cron.d/update-check

# Set the current working directory
WORKDIR /

# Expose necessary ports
EXPOSE 28015
EXPOSE 28016

# Setup default environment variables for the server
ENV RUST_SERVER_STARTUP_ARGUMENTS "-batchmode -load +server.secure 1"
ENV RUST_SERVER_IDENTITY "docker"
ENV RUST_SERVER_SEED "12345"
ENV RUST_SERVER_NAME "Rust Server [DOCKER]"
ENV RUST_SERVER_DESCRIPTION "This is a Rust server running inside a Docker container!"
ENV RUST_SERVER_URL "https://hub.docker.com/r/didstopia/rust-server/"
ENV RUST_SERVER_BANNER_URL ""
ENV RUST_RCON_WEB "1"
ENV RUST_RCON_PORT "28016"
ENV RUST_RCON_PASSWORD "docker"
ENV RUST_UPDATE_CHECKING "0"
ENV RUST_UPDATE_BRANCH "public"
ENV RUST_START_MODE "0"
ENV RUST_OXIDE_ENABLED "0"
ENV RUST_OXIDE_UPDATE_ON_BOOT "1"
ENV RUST_SERVER_WORLDSIZE "3500"
ENV RUST_SERVER_MAXPLAYERS "500"
ENV RUST_SERVER_SAVE_INTERVAL "600"

# Cleanup
ENV DEBIAN_FRONTEND newt

# Start the server
ENTRYPOINT ["./start.sh"]
