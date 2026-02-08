#!/bin/bash

# Entrypoint script for qlever-control Docker container

echo "======================================"
echo "QLever Control Docker Container"
echo "======================================"

# Verify installed tools
echo ""
echo "Verifying installed tools..."
echo "- Java version:"
java -version 2>&1 | head -n 1
echo "- jq version: $(jq --version)"
echo "- pipx version: $(pipx --version)"
echo "- qlever version: $(qlever --version 2>&1 | tail -1)"

# Optional: Test Docker connectivity to host
if [ "${TEST_DOCKER}" = "true" ]; then
    echo ""
    echo "Testing Docker connectivity to host..."
    if docker run --rm hello-world > /dev/null 2>&1; then
        echo "✓ Docker connectivity test PASSED: Can run containers on host"
    else
        echo "✗ Docker connectivity test FAILED: Cannot run containers on host"
        echo "  Make sure to mount the Docker socket: -v /var/run/docker.sock:/var/run/docker.sock"
    fi
fi

echo ""
echo "======================================"
echo "Container ready!"
echo "======================================"
echo ""

# Execute the main command
exec "$@"
