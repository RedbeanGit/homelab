#!/bin/sh
set -eu

# Default values
: ${EULA:=true}
: ${JAVA_OPTS:="-Xms1G -Xmx2G"}
: ${PROPERTIES_DIFFICULTY:="normal"}
: ${PROPERTIES_ENABLE_RCON:=false}
: ${PROPERTIES_GAMEMODE:="survival"}
: ${PROPERTIES_MAX_PLAYERS:="20"}
: ${PROPERTIES_MOTD:="A PaperMC Server"}

PAPERMC_STATIC_FOLDER="/opt/papermc"

print_env() {
  echo "Starting PaperMC ${PAPER_VERSION} with JVM options: ${JAVA_OPTS}"
}

ensure_eula() {
  if [ ! -f /data/eula.txt ]; then
    echo "eula=${EULA}" > /data/eula.txt
    echo "Created /data/eula.txt with eula=${EULA}"
  fi
}

ensure_paper() {
  if [ ! -f /data/paper.jar ]; then
    echo "Copying paper jar to /data/paper.jar"
    cp ${PAPER_STATIC_FOLDER}/paper.jar /data/paper.jar
    chmod 644 /data/paper.jar
  fi
}


ensure_configs() {
  if [ ! -f /data/paper.yml ]; then
    echo "Copying default paper.yml to /data/paper.yml"
    cp ${PAPER_STATIC_FOLDER}/paper.yml /data/paper.yml
    chmod 644 /data/paper.yml
  fi
  if [ ! -f /data/spigot.yml ]; then
    echo "Copying default spigot.yml to /data/spigot.yml"
    cp ${PAPER_STATIC_FOLDER}/spigot.yml /data/spigot.yml
    chmod 644 /data/spigot.yml
  fi
  if [ ! -f /data/server.properties ]; then
    echo "Copying default server.properties to /data/server.properties"
    cp ${PAPER_STATIC_FOLDER}/server.properties /data/server.properties
    chmod 644 /data/server.properties
  fi
}

update_properties() {
  if [ -n "${PROPERTIES_DIFFICULTY}" ]; then
    if ! grep -q "^difficulty=${PROPERTIES_DIFFICULTY}" /data/server.properties; then
      echo "Setting difficulty in server.properties"
      sed -i "s/^difficulty=.*/difficulty=${PROPERTIES_DIFFICULTY}/" /data/server.properties
    fi
  fi
  if [ "${PROPERTIES_ENABLE_RCON}" = "true" ]; then
    if ! grep -q "^enable-rcon=true" /data/server.properties; then
      echo "Enabling RCON in server.properties"
      sed -i 's/^enable-rcon=false/enable-rcon=true/' /data/server.properties
    fi
  fi
  if [ -n "${PROPERTIES_GAMEMODE}" ]; then
    if ! grep -q "^gamemode=${PROPERTIES_GAMEMODE}" /data/server.properties; then
      echo "Setting gamemode in server.properties"
      sed -i "s/^gamemode=.*/gamemode=${PROPERTIES_GAMEMODE}/" /data/server.properties
    fi
  fi
  if [ -n "${PROPERTIES_MAX_PLAYERS}" ]; then
    if ! grep -q "^max-players=${PROPERTIES_MAX_PLAYERS}" /data/server.properties; then
      echo "Setting max-players in server.properties"
      sed -i "s/^max-players=.*/max-players=${PROPERTIES_MAX_PLAYERS}/" /data/server.properties
    fi
  fi
  if ! grep -q "^motd=" /data/server.properties; then
    echo "Setting MOTD in server.properties"
    sed -i "s/^motd=.*/motd=${PROPERTIES_MOTD}/" /data/server.properties
  fi
}

print_env
ensure_eula
ensure_paper
ensure_configs
update_properties
cd /data

# Exec server as the container user (Dockerfile set USER to non-root)
exec java ${JAVA_OPTS} -jar paper.jar nogui
