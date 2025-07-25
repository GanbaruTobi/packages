# Reference: https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/
ARG UBUNTU_VERSION=22.04

# Build stage (no need to optimize for size)
FROM ubuntu:${UBUNTU_VERSION} AS build
WORKDIR /tmp

# Create superbuild project
COPY superbuild.cmake llvm.cmake ./
RUN echo 'cmake_minimum_required(VERSION 3.22)' > CMakeLists.txt && \
    echo 'project(llvm)' >> CMakeLists.txt && \
    echo 'include(superbuild.cmake)' >> CMakeLists.txt && \
    echo 'include(llvm.cmake)' >> CMakeLists.txt


# CMake APT repository
RUN \
apt update && \
apt install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    sudo 
# Install compilers to bootstrap LLVM
RUN \
apt update && \
apt install --no-install-recommends -y \
    cmake=3.22.1-1ubuntu1.22.04.2\
    python-is-python3 \
    git \
    make \
    ninja-build \
    libz-dev \
    libzstd-dev \
    libxml2-dev \
    flex \
    bison \
    build-essential

# Build LLVM (Ensures LLVM is installed into /tmp/build/llvm-prefix, which is then copied)
RUN \
cmake -B build "-DCMAKE_INSTALL_PREFIX=/tmp/build/install" "-DBUILD_SHARED_LIBS=ON" && \
cmake --build build

# Actual final image
FROM ubuntu:${UBUNTU_VERSION} AS llvm
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

# Copy LLVM installation from the build stage
# The 'llvm' project, configured via ExternalProject_Add in llvm.cmake,
# installs its artifacts into a sub-directory named 'llvm-prefix'
# within the superbuild's binary directory. Since WORKDIR is /tmp and
# the build directory is 'build', the path is /tmp/build/llvm-prefix.
COPY --from=build /tmp/build/install /usr/local/

# Install common development packages
RUN \
apt update && \
apt install --no-install-recommends -y \
    ca-certificates \
    gpg \
    wget \
    sudo \
    && \
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | \
gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | \
sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
apt update && \
rm /usr/share/keyrings/kitware-archive-keyring.gpg && \
apt install --no-install-recommends -y \
    kitware-archive-keyring \
    cmake=3.31.8-0kitware1ubuntu22.04.1 \
    cmake-data=3.31.8-0kitware1ubuntu22.04.1 \
    curl \
    python-is-python3 \
    python3-pip \
    git \
    git-lfs \
    make \
    ninja-build \
    libstdc++-12-dev \
    ncurses-dev \
    libz-dev \
    libzstd-dev \
    libxml2-dev \
    binutils \
    flex \
    bison \
    pkg-config \
    && \
apt autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
python -m pip --no-cache-dir install meson