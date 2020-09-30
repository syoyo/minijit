#!/bin/bash

curdir=`pwd`
distdir=`pwd`/dist-llvm-native
builddir=`pwd`/build-llvm-native

rm -rf ${builddir}
mkdir ${builddir}


# -DLLVM_OPTIMIZED_TABLEGEN=On : Without this, tblgen may become too slow to run

cd ${builddir} && cmake -G Ninja -S ../third_party/llvm-project/llvm \
  -DCMAKE_INSTALL_PREFIX=$distdir \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_TARGETS_TO_BUILD="host" \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DLLVM_OPTIMIZED_TABLEGEN=On \
  -DLLVM_ENABLE_ASSERTIONS=ON && cd ${curdir}

cmake --build ${builddir} && cmake --build ${builddir} --target install

# clang-tblgen need to be manually copied 
cp ${builddir}/bin/clang-tblgen ${distdir}/bin/
