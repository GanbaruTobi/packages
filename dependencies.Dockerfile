
FROM my-llvm-image4:latest AS build
WORKDIR /tmp
COPY \
    bitwuzla.cmake \
    bitwuzlaConfig.cmake.in \
    CMakeLists.txt  \
    gmp.cmake \
    GMPConfig.cmake.in \
    hash.py \
    llvm.cmake \
    superbuild.cmake \
    xed.cmake \
    XEDConfig.cmake.in \
    ubuntu-dependencies.sh \
    ./

# Install remill cross-compilation dependencies
RUN \
./ubuntu-dependencies.sh && \
rm -rf /var/lib/apt/lists/*

# Build dependencies
RUN \
mkdir /dependencies && \
python hash.py --debug --simple > /dependencies/hash.txt && \
cmake -B build "-DCMAKE_INSTALL_PREFIX=/dependencies" -DUSE_EXTERNAL_LLVM=ON && \
cmake --build build && \
rm -rf build

# Actual final image
FROM my-llvm-image4:latest AS dependencies
LABEL org.opencontainers.image.source=https://github.com/LLVMParty/packages

COPY --from=build /dependencies /dependencies
ENV CMAKE_PREFIX_PATH="/dependencies" \
    LD_LIBRARY_PATH="/dependencies/lib" \
    PATH="/dependencies/bin:$PATH"
