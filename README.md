# packages

## was ich gemacht hab (dauert ca 2 std auf meinem Laptop)

```
docker build -t my-llvm-image4:latest -f llvm.Dockerfile .
docker build -t my-dependencies-image3:latest -f dependencies.Dockerfile
```

## notiz
ld_preload
ld_library_path
patchelf

## original Build instructions

**Note**: End users do not need to run these commands, they are just here for reference.

Build `packages/ubuntu`:

```
export LLVM_TAG="ghcr.io/llvmparty/packages/ubuntu:22.04-llvm19.1.7"
docker buildx build --platform linux/arm64 -t "$LLVM_TAG" . -f llvm.Dockerfile
docker buildx build --platform linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
docker buildx build --platform linux/arm64,linux/amd64 -t "$LLVM_TAG" . -f llvm.Dockerfile
docker push "$LLVM_TAG"
```

Build `packages/dependencies`:

```
export HASH=$(python hash.py --simple | cut -c 1-8)
export DATE="$(date +"%Y%m%d")"
export TAG="ghcr.io/llvmparty/packages/dependencies:22.04-llvm19-$DATE-$HASH"
docker buildx build --platform linux/arm64 -t "$TAG" . -f dependencies.Dockerfile
docker buildx build --platform linux/amd64 -t "$TAG" . -f dependencies.Dockerfile
docker buildx build --platform linux/arm64,linux/amd64 -t "$TAG" . -f dependencies.Dockerfile
docker push "$TAG"
```

References:
- https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/
- https://docs.docker.com/build/building/multi-stage/
