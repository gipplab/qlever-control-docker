# qlever-control-docker

Run qlever-control from within a Docker container with all required tools pre-installed.

## Features

This Docker container includes:
- **Java (OpenJDK 11)** - Required for qlever operations
- **jq** - JSON processor for data manipulation
- **pipx** - Python package manager
- **qlever** - Installed via pipx
- **Docker CLI** - To run Docker commands on the host VM

## Prerequisites

- Docker installed on your host machine
- Docker Compose (optional, but recommended)

## Usage

### Using Docker Compose (Recommended)

1. Build and start the container:
   ```bash
   docker-compose up -d
   ```

2. Access the container:
   ```bash
   docker-compose exec qlever-control bash
   ```

3. Stop the container:
   ```bash
   docker-compose down
   ```

### Using Docker directly

1. Build the image:
   ```bash
   docker build -t qlever-control:latest .
   ```

2. Run the container with Docker socket mounted:
   ```bash
   docker run -it --rm \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v $(pwd)/workspace:/workspace \
     qlever-control:latest
   ```

### Testing Docker Connectivity

To test if the container can run Docker commands on the host, set the `TEST_DOCKER` environment variable:

```bash
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e TEST_DOCKER=true \
  qlever-control:latest
```

Or with docker-compose, edit the `docker-compose.yml` file and set:
```yaml
environment:
  - TEST_DOCKER=true
```

This will run `docker run hello-world` on startup to verify connectivity.

## Installed Tools

Once inside the container, you can use:
- `java -version` - Check Java installation
- `jq --version` - Check jq installation
- `pipx --version` - Check pipx installation
- `qlever --version` - Check qlever installation
- `docker ps` - Run Docker commands on the host

## Volumes

- `/var/run/docker.sock` - Docker socket for running Docker commands on host
- `/workspace` - Working directory for your files

## Environment Variables

- `TEST_DOCKER` - Set to `true` to test Docker connectivity on container startup (default: `false`)

## Security Note

Mounting the Docker socket (`/var/run/docker.sock`) gives the container full access to the Docker daemon on the host. This is equivalent to root access on the host machine. Only use this in trusted environments.
