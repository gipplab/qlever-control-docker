# qlever-control-docker

Run qlever-control from within a Docker container with all required tools pre-installed.

## Features

This Docker container includes:
- **Java (OpenJDK 17)** - Required for qlever operations
- **jq** - JSON processor for data manipulation
- **pipx** - Python package manager
- **qlever** - Installed via pipx
- **Docker CLI** - To run Docker commands on the host VM

Base image: **Debian Bookworm (Slim)**

## Automated Builds

Docker images are automatically built and pushed to GitHub Container Registry (ghcr.io) via GitHub Actions:
- **On push to main/master**: Tagged as `latest`
- **On pull requests**: Tagged with PR number
- **On releases**: Tagged with version numbers

Pull the pre-built image:
```bash
docker pull ghcr.io/gipplab/qlever-control:latest
```

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

### Using Docker Stack (Docker Swarm)

For production deployments using Docker Swarm, use the provided `docker-stack.yml` template:

1. Initialize Docker Swarm (if not already initialized):
   ```bash
   docker swarm init
   ```

2. Deploy the stack:
   ```bash
   docker stack deploy -c docker-stack.yml qlever
   ```

3. Check the service status:
   ```bash
   docker stack services qlever
   docker service ps qlever_qlever-control
   ```

4. Access the container:
   ```bash
   # Get the container ID/name
   docker service ps qlever_qlever-control --filter desired-state=running --format '{{.Name}}.{{.ID}}'
   
   # Access the container (replace CONTAINER_ID with actual ID from above)
   docker exec -it qlever_qlever-control.1.CONTAINER_ID bash
   ```
   
   Or use this one-liner (if only one container is running):
   ```bash
   docker exec -it $(docker ps -q -f name=qlever_qlever-control) bash
   ```

5. Remove the stack:
   ```bash
   docker stack rm qlever
   ```

The `docker-stack.yml` template uses the latest pre-built image from GitHub Container Registry (`ghcr.io/gipplab/qlever-control:latest`) and includes:
- Resource limits and reservations
- Restart policies
- Update and rollback configurations
- Persistent volume for workspace data

**Note:** The service runs with `replicas: 1` because the Docker socket mount prevents horizontal scaling. See the Security Note section below for important security considerations when mounting the Docker socket.

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

## Testing

A test script is provided to verify all functionality:

```bash
./test.sh
```

This will:
- Build the Docker image
- Verify all tools are installed correctly
- Test Docker connectivity
- Test docker-compose functionality
- Test workspace mounting
