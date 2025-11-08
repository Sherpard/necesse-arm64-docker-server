# ============================================================
# 🧩 Necesse Dedicated Server — ARM64 friendly build
# ============================================================
FROM eclipse-temurin:21-jre-jammy

LABEL maintainer="Sherpard2 <xianbtrigo@gmail.com>"
LABEL description="Necesse Dedicated Server for Docker (ARM64-ready)"

# Install minimal tools needed for updates and archive handling
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget unzip ca-certificates net-tools \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -d /home/steam steam

WORKDIR /home/steam

# Copy scripts
COPY --chmod=750 --chown=steam:steam fetch-latest-server.sh /usr/local/bin/fetch-latest-server.sh
COPY --chmod=750 --chown=steam:steam start-server.sh /usr/local/bin/start-server.sh
# Create required directories
RUN mkdir -p /home/steam/server /home/steam/data /home/steam/cache \
    && chown -R steam:steam /home/steam

# Run as non-root user for security
USER steam

# Expose default Necesse port (UDP)
EXPOSE 14159/udp

HEALTHCHECK --interval=60s --timeout=3s --start-period=10s --retries=5 \
    CMD netstat -nlu | grep 14159 || exit 1

# Start the server
ENTRYPOINT ["/usr/local/bin/start-server.sh"]