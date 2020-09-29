rm -rf build-llvm-project
mkdir build-llvm-project

dist_dir=`pwd`/dist

#  -DLLVM_USE_LINKER=lld \

cd build-llvm-project && CXX=clang++ CC=clang cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DLLVM_BUILD_TOOLS=Off \
  -DLLVM_TARGETS_TO_BUILD="host;NVPTX" \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_ENABLE_EH=On \
  -DCMAKE_INSTALL_PREFIX=${dist_dir} \
  ../third_party/llvm-project/llvm && cmake --build . && cmake --install .


