#!/bin/sh
set -eu

# Default values
: ${EULA:=true}
: ${PAPER_JAR:=/opt/papermc/paper.jar}
: ${JAVA_OPTS:="-Xms1G -Xmx2G"}

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
    cp ${PAPER_JAR} /data/paper.jar
    chmod 644 /data/paper.jar
  fi
}

print_env
ensure_eula
ensure_paper

cd /data

# Exec server as the container user (Dockerfile set USER to non-root)
exec java ${JAVA_OPTS} -jar paper.jar nogui
