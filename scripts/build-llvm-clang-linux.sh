rm -rf build-llvm-project
mkdir build-llvm-project

dist_dir=`pwd`/dist

#  -DLLVM_USE_LINKER=lld \

# reference: https://boxbase.org/entries/2018/jun/11/minimal-llvm-build/
#
# config:
#  * Use MinSizeRel to save storage
#  * Enable NVPTX(CUDA) target
#  * No terminfo(on linux)
#  * RTTI and EH on
#  * build libLLVM.so and libclang.so
#

cd build-llvm-project && CXX=clang++ CC=clang cmake \
  -G Ninja \
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


