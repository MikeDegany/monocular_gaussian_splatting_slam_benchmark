#!/bin/bash

###############################################################################
# @file      setup_nvidia_docker.sh
# @brief     Install NVIDIA Container Toolkit for GPU support in Docker
# @author    Seungwon Choi
# @email     csw3575@snu.ac.kr
# @date      2025-11-23
# @copyright Seungwon Choi. All rights reserved.
###############################################################################

set -e

echo "=========================================="
echo "NVIDIA Container Toolkit 설치 시작"
echo "=========================================="
echo ""

# Check if NVIDIA GPU driver is installed
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ Error: NVIDIA GPU driver not found!"
    echo "Please install NVIDIA driver first."
    exit 1
fi

echo "✓ NVIDIA GPU driver detected:"
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
echo ""

# Add NVIDIA Container Toolkit repository
echo "📦 Adding NVIDIA Container Toolkit repository..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
echo ""

# Update package list
echo "📋 Updating package list..."
sudo apt-get update
echo ""

# Install NVIDIA Container Toolkit
echo "⚙️  Installing NVIDIA Container Toolkit..."
sudo apt-get install -y nvidia-container-toolkit
echo ""

# Configure Docker daemon
echo "🔧 Configuring Docker to use NVIDIA runtime..."
sudo nvidia-ctk runtime configure --runtime=docker
echo ""

# Restart Docker service
echo "🔄 Restarting Docker service..."
sudo systemctl restart docker
echo ""

# Test GPU access
echo "🧪 Testing GPU access in Docker..."
if docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi; then
    echo ""
    echo "=========================================="
    echo "✓ NVIDIA Container Toolkit 설치 완료!"
    echo "=========================================="
    echo ""
    echo "이제 다음 명령어로 MonoGS를 실행할 수 있습니다:"
    echo "  cd ~/monocular_gaussian_splatting_slam_benchmark/installs/MonoGS"
    echo "  ./run.sh"
    echo ""
else
    echo ""
    echo "❌ Error: GPU access test failed!"
    echo "Please check your Docker and NVIDIA driver installation."
    exit 1
fi
