builddir=`pwd`/build-llvm-clang-cl
rm -rf ${builddir}
mkdir ${builddir}

dist_dir=`pwd`/dist-win64-cl

cd ${builddir}
cmake -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="../cmake/clang-cl-msvc-wsl.cmake" \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DHOST_ARCH=x64 \
  -DLLVM_NATIVE_TOOLCHAIN="/home/syoyo/local/clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04/" \
  -DMSVC_BASE:FILEPATH="/mnt/c/Users/syoyo/msvc/MSVC" \
  -DWINSDK_BASE="/mnt/c/Users/syoyo/msvc/sdk" \
  -DWINSDK_VER="10.0.18362.0" \
  -DLLVM_BUILD_TOOLS=Off \
  -DLLVM_TARGETS_TO_BUILD="host;NVPTX" \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_EH=On \
  -DCMAKE_INSTALL_PREFIX=${dist_dir} \
  ../third_party/llvm-project/llvm && cmake --build . && cmake --install .

