FROM debian:bookworm-slim

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install all dependencies in fewer layers for better caching
# Note: docker.io (Debian's Docker package) is used instead of docker-ce-cli for better
# reliability in various build environments. The container uses the host's Docker engine
# via socket mount, so CLI compatibility is typically not an issue.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    docker.io \
    openjdk-17-jdk \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install qlever from official package repository
# See https://docs.qlever.dev/quickstart/#debian-and-ubuntu
RUN wget -qO - https://packages.qlever.dev/pub.asc | gpg --dearmor | tee /usr/share/keyrings/qlever.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/qlever.gpg] https://packages.qlever.dev/ $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") main" | tee /etc/apt/sources.list.d/qlever.list && \
    apt-get update && \
    apt-get install -y qlever && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Create entrypoint script that optionally tests Docker connectivity
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
