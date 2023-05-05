#!/bin/bash

set -e
set -x

# llvm-mingw cross compile
# Assume Ninja is installed on your system
curdir=`pwd`

# Set path to llvm-mingw in env var.
export LLVM_MINGW_DIR=/mnt/nvme01/local/llvm-mingw-20230427-ucrt-ubuntu-20.04-x86_64/

builddir=${curdir}/build-llvm-mingw

rm -rf ${builddir}
mkdir ${builddir}

# -DMINIJIT_CUSTOM_LINKER=lld \

cd ${builddir} && cmake \
  -DCMAKE_TOOLCHAIN_FILE=${curdir}/cmake/llvm-mingw-cross.cmake \
  -G "Ninja" \
  -DCMAKE_VERBOSE_MAKEFILE=1 \
  -DMINIJIT_EXTERNAL_LLVM_PROJECT=On \
  -DMINIJIT_LLVM_PROJECT_DIR=${curdir}/dist-llvm-w64-mingw32/ \
  ..

cd ${curdir}
