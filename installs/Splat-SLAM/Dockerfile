###############################################################################
# @file      Dockerfile
# @brief     Docker environment setup for Splat-SLAM
# @author    Mike Degany
# @email     mike.degany@gmail.com
# @date      2025-12-06
# @copyright Mike Degany. All rights reserved.
###############################################################################
# Splat-SLAM Docker Environment
# Based on official installation guide: https://github.com/google-research/Splat-SLAM

# Base image with CUDA 11.7
FROM nvidia/cuda:11.7.1-devel-ubuntu22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
# Limit parallel jobs to prevent OOM during compilation (4 is a safe number)
ENV MAX_JOBS=4
# Force CUDA compilation
ENV FORCE_CUDA=1
ENV TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6+PTX"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    wget \
    curl \
    cmake \
    ninja-build \
    libeigen3-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libglfw3 \
    libglfw3-dev \
    build-essential \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

WORKDIR /workspace

# Upgrade pip and install build tools
RUN pip install --upgrade pip setuptools wheel ninja

# Install PyTorch with CUDA 11.7 support (matching official guide)
RUN pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 \
    --extra-index-url https://download.pytorch.org/whl/cu117

# Pin NumPy to 1.x to avoid compatibility issues with compiled modules
RUN pip install "numpy<2"

# Clone the repo with submodules (Step 1 from official guide)
RUN git clone --recursive https://github.com/google-research/Splat-SLAM.git

WORKDIR /workspace/Splat-SLAM

# Update depth rendering hyperparameter (Step 4 from official guide)
# Change 0.2f to 0.001f for monocular scale ambiguity
RUN sed -i 's/p_view.z <= 0.2f/p_view.z <= 0.001f/g' \
    thirdparty/diff-gaussian-rasterization-w-pose/cuda_rasterizer/auxiliary.h

# Install thirdparty dependencies (Step 5 from official guide)
# Using editable installs (-e) as per official instructions
# --no-build-isolation is required because setup.py imports torch

# --- Lietorch ---
WORKDIR /workspace/Splat-SLAM/thirdparty/lietorch
RUN python -m pip install -e . --no-build-isolation

# --- Diff-Gaussian-Rasterization with Pose ---
WORKDIR /workspace/Splat-SLAM/thirdparty/diff-gaussian-rasterization-w-pose
RUN python -m pip install -e . --no-build-isolation

# --- Simple-KNN ---
WORKDIR /workspace/Splat-SLAM/thirdparty/simple-knn
RUN python -m pip install -e . --no-build-isolation

# --- Evaluate 3D Reconstruction Lib ---
WORKDIR /workspace/Splat-SLAM/thirdparty/evaluate_3d_reconstruction_lib
RUN python -m pip install -e . --no-build-isolation

# Return to main directory
WORKDIR /workspace/Splat-SLAM

# Add thirdparty modules to PYTHONPATH as backup for editable installs
ENV PYTHONPATH="/workspace/Splat-SLAM/thirdparty/lietorch:/workspace/Splat-SLAM/thirdparty/diff-gaussian-rasterization-w-pose:/workspace/Splat-SLAM/thirdparty/simple-knn:/workspace/Splat-SLAM/thirdparty/evaluate_3d_reconstruction_lib:${PYTHONPATH}"

# Install main package (Step 7 from official guide)
RUN pip install -e . --no-build-isolation

# Install remaining requirements with no-build-isolation
# CRITICAL: Explicitly pin torch in the install to prevent pip from upgrading it
# We add torch==1.13.1+cu117 to the list to lock the version
RUN pip install --no-build-isolation \
    torch==1.13.1+cu117 torchvision==0.14.1+cu117 \
    pillow imageio joblib pandas scikit-image scikit-learn scipy seaborn \
    PyOpenGL-accelerate pyrender ninja setuptools \
    torch-scatter timm plyfile==0.8.1 tqdm opencv-python==4.8.1.78 \
    munch trimesh evo open3d==0.17.0 torchmetrics imgviz lpips rich \
    kornia tensorboard \
    --extra-index-url https://download.pytorch.org/whl/cu117

# Install pytorch-lightning without deps (Step 7 final)
RUN pip install pytorch-lightning==1.9 --no-deps

# Verify installation (Step 6 from official guide - moved to end)
RUN python -c "import torch; import lietorch; import simple_knn; import diff_gaussian_rasterization; print('CUDA available:', torch.cuda.is_available())"

# Create pretrained weights directory
RUN mkdir -p pretrained

# Note: Pretrained weights should be mounted or copied in:
# - pretrained/droid.pth
# - pretrained/omnidata_dpt_depth_v2.ckpt
# ("The middle_fine.pt decoder will not be used and can be removed.")

CMD ["/bin/bash"]
