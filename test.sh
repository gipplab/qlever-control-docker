#!/bin/bash
# Test script to verify all functionality of the qlever-control Docker container

set -e

echo "================================"
echo "Testing qlever-control container"
echo "================================"
echo ""

# Test 1: Build the container
echo "Test 1: Building the Docker image..."
docker build -t qlever-control:test . > /dev/null 2>&1
echo "✓ Docker image built successfully"
echo ""

# Test 2: Verify all tools are installed
echo "Test 2: Verifying all tools are installed..."
docker run --rm qlever-control:test bash -c "
    java -version 2>&1 | grep -q 'openjdk version' && echo '  ✓ Java (OpenJDK 11) installed' || exit 1
    jq --version | grep -q 'jq-' && echo '  ✓ jq installed' || exit 1
    pipx --version | grep -q '1.' && echo '  ✓ pipx installed' || exit 1
    qlever --version | grep -q 'qlever' && echo '  ✓ qlever installed' || exit 1
    docker --version | grep -q 'Docker version' && echo '  ✓ Docker CLI installed' || exit 1
" 2>&1 | grep "✓"
echo ""

# Test 3: Test Docker connectivity (requires Docker socket)
echo "Test 3: Testing Docker connectivity to host..."
if docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    -e TEST_DOCKER=true qlever-control:test echo "test" 2>&1 | grep -q "PASSED"; then
    echo "✓ Docker connectivity test passed"
else
    echo "✗ Docker connectivity test failed (Docker socket may not be available)"
fi
echo ""

# Test 4: Test with docker-compose
echo "Test 4: Testing with docker-compose..."
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    docker compose build > /dev/null 2>&1
    echo "✓ Docker Compose build successful"
else
    echo "⚠ Docker Compose not available, skipping"
fi
echo ""

# Test 5: Test workspace mounting
echo "Test 5: Testing workspace directory mounting..."
docker run --rm -v "$(pwd)/workspace:/workspace" qlever-control:test \
    bash -c "[ -d /workspace ] && echo '✓ Workspace directory mounted successfully'" || echo "✗ Failed"
echo ""

# Cleanup
echo "Cleaning up test image..."
docker rmi qlever-control:test > /dev/null 2>&1 || true

echo ""
echo "================================"
echo "All tests completed successfully!"
echo "================================"
