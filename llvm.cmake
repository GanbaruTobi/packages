option(LLVM_ENABLE_ASSERTIONS "Enable assertions in LLVM" ON)

set(LLVM_ARGS
    "-DLLVM_ENABLE_PROJECTS:STRING=lld;clang;clang-tools-extra"
    "-DLLVM_ENABLE_ASSERTIONS:STRING=${LLVM_ENABLE_ASSERTIONS}"
    "-DLLVM_ENABLE_DUMP:STRING=${LLVM_ENABLE_ASSERTIONS}"
    "-DLLVM_ENABLE_RTTI:STRING=ON"
    "-DLLVM_ENABLE_LIBEDIT:STRING=OFF"
    "-DLLVM_PARALLEL_LINK_JOBS:STRING=1"
    "-DLLVM_ENABLE_DIA_SDK:STRING=OFF"
    # This is meant for LLVM development, we use the DYLIB option instead
    "-DBUILD_SHARED_LIBS:STRING=OFF"
    "-DLLVM_LINK_LLVM_DYLIB:STRING=${BUILD_SHARED_LIBS}"
)

if(USE_SANITIZERS)
    list(APPEND LLVM_ARGS "-DLLVM_USE_SANITIZER:STRING=Address;Undefined")
endif()

ExternalProject_Add(llvm
    URL
        "https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/llvm-project-20.1.8.src.tar.xz"
    URL_HASH
        "SHA256=6898f963c8e938981e6c4a302e83ec5beb4630147c7311183cf61069af16333d"
    CMAKE_CACHE_ARGS
        ${CMAKE_ARGS}
        ${LLVM_ARGS}
    CMAKE_GENERATOR
        "Ninja"
    SOURCE_SUBDIR
        "llvm"
)
