FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install basic dependencies including ca-certificates first
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (using docker.io from Ubuntu repos - more reliable)
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

# Install Java (OpenJDK)
RUN apt-get update && apt-get install -y \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install jq (JSON processor)
RUN apt-get update && apt-get install -y \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install pipx and Python
RUN apt-get update && apt-get install -y \
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
