# https://alexreinking.com/blog/how-to-use-cmake-without-the-agonizing-pain-part-1.html
cmake_minimum_required(VERSION 3.22)

project(dependencies)

option(USE_EXTERNAL_LLVM "Do not compile LLVM as part of the superbuild, use an external one instead" OFF)
option(USE_SANITIZERS "Use ASan and UBSan" OFF)

if(USE_EXTERNAL_LLVM)
    if(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin" AND NOT CMAKE_PREFIX_PATH)
        execute_process(
            COMMAND brew --prefix llvm
            RESULT_VARIABLE BREW_LLVM
            OUTPUT_VARIABLE BREW_LLVM_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if(BREW_LLVM EQUAL 0 AND EXISTS "${BREW_LLVM_PREFIX}")
            set(CMAKE_PREFIX_PATH "${BREW_LLVM_PREFIX}")
            message(STATUS "Found LLVM keg installed by Homebrew at ${BREW_LLVM_PREFIX}")
        else()
            message(FATAL_ERROR "LLVM not found, to install: brew install llvm")
        endif()
    endif()
    find_package(LLVM CONFIG REQUIRED)
    message(STATUS "LLVM ${LLVM_PACKAGE_VERSION}: ${LLVM_DIR}")
endif()

if(USE_SANITIZERS)
    list(APPEND CMAKE_C_FLAGS "-fsanitize=address,undefined")
    list(APPEND CMAKE_CXX_FLAGS "-fsanitize=address,undefined")
endif()

include(superbuild.cmake)

# Meson is necessary to build bitwuzla
find_program(meson_EXECUTABLE meson NO_CACHE NO_PACKAGE_ROOT_PATH NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_INSTALL_PREFIX NO_CMAKE_FIND_ROOT_PATH)
if(meson_EXECUTABLE STREQUAL "meson_EXECUTABLE-NOTFOUND")
    message(FATAL_ERROR "Could not find 'meson' in the PATH")
endif()
message(STATUS "meson: ${meson_EXECUTABLE}")

simple_git(https://github.com/nlohmann/json v3.11.3
    "-DJSON_BuildTests:STRING=OFF"
)
simple_git(https://github.com/ToruNiina/toml11 2a18a89008d3daac6d8f9db03ddd582173032c7a # master (2023-06-06)
    "-DCMAKE_CXX_STANDARD:STRING=11"
)
simple_git(https://github.com/yhirose/cpp-httplib v0.13.1
    "-DHTTPLIB_USE_OPENSSL_IF_AVAILABLE:STRING=OFF"
    "-DHTTPLIB_IS_USING_BROTLI:STRING=OFF"
    "-DHTTPLIB_USE_BROTLI_IF_AVAILABLE:STRING=OFF"
)
simple_git(https://github.com/gflags/gflags 52e94563eba1968783864942fedf6e87e3c611f4
)
simple_git(https://github.com/google/glog v0.7.1
    "-DGFLAGS_USE_TARGET_NAMESPACE:STRING=ON"
    "-DBUILD_TESTING:STRING=OFF"
)
simple_git(https://github.com/google/googletest v1.15.2
    "-Dgtest_force_shared_crt:STRING=ON"
    "-DGFLAGS_USE_TARGET_NAMESPACE:STRING=ON"
)
simple_git(https://github.com/redis/hiredis 294782041ef5841293dea3acc8ca9a28597bedc8)
simple_git(https://github.com/Tessil/ordered-map 46adc0e4720e9d00b6d63f62168840a086ab26e0)
simple_git(https://github.com/fmtlib/fmt 11.2.0
    "-DFMT_DOC:STRING=OFF"
    "-DFMT_TEST:STRING=OFF"
    "-DFMT_SYSTEM_HEADERS:STRING=ON"
)

simple_git(https://github.com/gabime/spdlog 9ecdf5c8a1a3ace5673f9fd1857da1b6375b5114
    "-DSPDLOG_FMT_EXTERNAL:STRING=ON"
    "-DSPDLOG_SYSTEM_INCLUDES:STRING=ON"
    "-DSPDLOG_BUILD_EXAMPLE:STRING=OFF"
)
simple_git(https://github.com/lief-project/LIEF 2ff359890ebb066d48abd631a830c2baeb7cf0e5
    "-DLIEF_EXAMPLES:STRING=OFF"
    "-DLIEF_USE_CCACHE:STRING=OFF"
)
simple_git(https://github.com/capstone-engine/capstone 5.0.6
    "-DCAPSTONE_BUILD_TESTS:STRING=OFF"
    "-DCAPSTONE_BUILD_CSTOOL:STRING=OFF"
)
simple_git(https://github.com/Z3Prover/z3 z3-4.13.2
    "-DZ3_BUILD_LIBZ3_SHARED:STRING=OFF"
)
simple_git(https://github.com/LLVMParty/minisat modern-package-v1
    "-DBUILD_SHARED_LIBS:STRING=OFF"
)
simple_git(https://github.com/stp/stp a9bc247d98cd98213b2d0f6821dc51b823c50483
    "-DBUILD_EXECUTABLES:STRING=OFF"
    "-DSTATICCOMPILE:STRING=ON"
)
include(xed.cmake)
include(gmp.cmake)
include(bitwuzla.cmake)
if(NOT USE_EXTERNAL_LLVM)
    include(llvm.cmake)
endif()
simple_git(https://github.com/kyle-elliott/remill 799a7b93b61db5b1834f48efe247e2d4c55b0182
    "-DUSE_SYSTEM_DEPENDENCIES:STRING=ON"
    "-DREMILL_ENABLE_TESTING:STRING=OFF"
)


simple_git(https://github.com/LLVMParty/alive2 cmake-package-souper-v7)
