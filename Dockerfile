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
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    && rm -rf /var/lib/apt/lists/*

# Ensure pipx path is set
ENV PATH="/root/.local/bin:${PATH}"

# Install qlever using pipx
RUN pipx install qlever && pipx ensurepath

# Set working directory
WORKDIR /workspace

# Create entrypoint script that optionally tests Docker connectivity
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
