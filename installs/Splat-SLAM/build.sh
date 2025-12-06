###############################################################################
# @file      build.sh
# @brief     Build script for Splat-SLAM Docker image
# @author    Mike Degany
# @email     mike.degany@gmail.com
# @date      2025-12-06
# @copyright Mike Degany. All rights reserved.
###############################################################################

echo "Building Splat-SLAM Docker image..."
docker build -t splat-slam:latest .

if [ $? -eq 0 ]; then
    echo "✓ Splat-SLAM Docker image built successfully!"
    echo "You can now run the container with: docker run -it splat-slam:latest"
else
    echo "✗ Failed to build Splat-SLAM Docker image"
    exit 1
fi