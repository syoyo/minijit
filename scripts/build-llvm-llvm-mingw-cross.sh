#!/bin/bash

set -e

# llvm-mingw cross compile
# Assume native llvm/tools are built using scripts/build-llvm-native-linux.sh and installed on
# `pwd`/dist-llvm/native
# Assume Ninja is installed on your system

# --- config ---

LLVM_MINGW_PATH=${LLVM_MINGW_DIR:-/mnt/data/local/llvm-mingw-20200325-ubuntu-18.04}

# --------------

echo "Use llvm-mingw path: " ${LLVM_MINGW_PATH}

curdir=`pwd`
distdir=`pwd`/dist-llvm-w64-mingw32
native_distdir=`pwd`/dist-llvm-native
builddir=`pwd`/build-llvm-mingw-cross

rm -rf ${builddir}
mkdir ${builddir}

LLVM_TBLGEN_PATH=${native_distdir}/bin/llvm-tblgen
CLANG_TBLGEN_PATH=${native_distdir}/bin/clang-tblgen
LLVM_CONFIG_FILENAME=${native_distdir}/bin/llvm-config


# LLVM_BUILD_LLVM_DYLIB=On: build libLLVM.dll
# turn off libxml2 since it requires iconv library
cd ${builddir} && cmake -G Ninja ../third_party/llvm-project/llvm \
   -DCMAKE_VERBOSE_MAKEFILE=1 \
   -DCMAKE_BUILD_TYPE=MinSizeRel \
   -DCMAKE_CROSSCOMPILING=True \
   -DCMAKE_SYSTEM_NAME=Windows \
   -DCMAKE_INSTALL_PREFIX=${distdir} \
   -DLLVM_TABLEGEN=${LLVM_TBLGEN_PATH} \
   -DCLANG_TABLEGEN=${CLANG_TBLGEN_PATH} \
   -DLLVM_CONFIG_PATH=${LLVM_CONFIG_FILENAME} \
   -DCMAKE_C_COMPILER=${LLVM_MINGW_PATH}/bin/x86_64-w64-mingw32-gcc \
   -DCMAKE_CXX_COMPILER=${LLVM_MINGW_PATH}/bin/x86_64-w64-mingw32-g++ \
   -DCMAKE_RC_COMPILER=${LLVM_MINGW_PATH}/bin/x86_64-w64-mingw32-windres \
   -DLLVM_ENABLE_LIBXML2=Off \
   -DLLVM_ENABLE_PROJECTS="clang" \
   -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
   -DLLVM_INCLUDE_EXAMPLES=Off \
   -DLLVM_INCLUDE_TESTS=Off \
   -DLLVM_INCLUDE_GO_TESTS=Off \
   -DLLVM_INCLUDE_BENCHMARKS=Off \
   -DLLVM_INCLUDE_DOCS=Off \
   -DLLVM_ENABLE_TERMINFO=OFF \
   -DLLVM_ENABLE_RTTI=ON \
   -DLLVM_ENABLE_EH=On \
   -DLLVM_BUILD_LLVM_DYLIB=On \
   -DLLVM_ENABLE_ASSERTIONS=ON && cd ${curdir}

cmake --build ${builddir} && cmake --build ${builddir} --target install


cd ${curdir}
