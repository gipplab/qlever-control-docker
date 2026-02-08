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
    && rm -rf /var/lib/apt/lists/*

# Install qlever using pip (recommended for platforms without native packages)
# See https://docs.qlever.dev/quickstart/
# Using --break-system-packages as we're in a containerized environment without system package conflicts
RUN python3 -m pip install --break-system-packages qlever

# Set working directory
WORKDIR /workspace

# Create entrypoint script that optionally tests Docker connectivity
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
