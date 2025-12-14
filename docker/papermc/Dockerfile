ARG PAPER_VERSION=1.21.10-117
ARG PAPER_DOWNLOAD_URL="https://fill-data.papermc.io/v1/objects/a61a0585e203688f606ca3a649760b8ba71efca01a4af7687db5e41408ee27aa/paper-1.21.10-117.jar"

################################################################################
# Builder stage: download the Paper jar (keeps final image small)
FROM curlimages/curl:8.4.0 AS downloader
ARG PAPER_VERSION
ARG PAPER_DOWNLOAD_URL
WORKDIR /tmp
RUN --mount=type=cache,target=/root/.cache \
    curl -fSL -o paper-${PAPER_VERSION}.jar ${PAPER_DOWNLOAD_URL} \
    && chmod 644 paper-${PAPER_VERSION}.jar

################################################################################
# Runtime stage: minimal JRE, non-root user, smaller attack surface
FROM eclipse-temurin:21-jre-jammy AS runtime

ARG PAPER_VERSION

LABEL org.opencontainers.image.title="papermc-server" \
      org.opencontainers.image.description="PaperMC Minecraft server (pinned build)" \
      org.opencontainers.image.version="${PAPER_VERSION}"
ENV PAPER_VERSION=${PAPER_VERSION}
ENV PAPER_STATIC_FOLDER=/opt/papermc
ENV JAVA_OPTS="-Xms1G -Xmx2G"

# Create non-root user and directories
RUN groupadd -g 1000 minecraft \
  && useradd -m -u 1000 -g minecraft minecraft \
  && mkdir -p /opt/papermc /data \
  && chown -R minecraft:minecraft /opt/papermc /data

COPY --from=downloader /tmp/paper-${PAPER_VERSION}.jar ${PAPER_STATIC_FOLDER}/paper.jar
COPY server.properties paper.yml spigot.yml ${PAPER_STATIC_FOLDER}/
RUN chown minecraft:minecraft ${PAPER_STATIC_FOLDER}/* && chmod 644 ${PAPER_STATIC_FOLDER}/paper.jar

# Add entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && chown root:root /usr/local/bin/entrypoint.sh

VOLUME ["/data"]
WORKDIR /data
EXPOSE 25565/tcp

# Install netcat for HEALTHCHECK (small and useful to detect port availability)
RUN apt-get update && apt-get install -y --no-install-recommends netcat && rm -rf /var/lib/apt/lists/*

USER minecraft

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 CMD nc -z localhost 25565 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["java"]
