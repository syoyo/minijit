# llvm-mingw cross compile
# Assume Ninja is installed on your system
curdir=`pwd`

# Set path to llvm-mingw in env var.
export LLVM_MINGW_DIR=/mnt/data/local/llvm-mingw-20200325-ubuntu-18.04/

builddir=${curdir}/build-llvm-project-llvm-mingw-cross
dist_dir=${curdir}/dist-win64

rm -rf ${builddir}
mkdir ${builddir}

cd ${builddir} && cmake \
  -DCMAKE_TOOLCHAIN_FILE=${curdir}/cmake/llvm-mingw-cross.cmake \
  -G "Ninja" \
  -DCMAKE_VERBOSE_MAKEFILE=1 \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DLLVM_BUILD_TOOLS=Off \
  -DLLVM_TARGETS_TO_BUILD="host;NVPTX" \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_EH=On \
  -DLLVM_BUILD_LLVM_DYLIB="YES" \
  -DCMAKE_INSTALL_PREFIX=${dist_dir} \
  ../third_party/llvm-project/llvm && cmake --build . && cmake --install .

cd ${curdir}
