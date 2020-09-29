rm -rf build
mkdir build

CXX=clang++ CC=clang cmake -DMINIJIT_USE_CCACHE=On -DMINIJIT_CUSTOM_LINKER=lld -DCMAKE_BUILD_TYPE=MinSizeRel -Bbuild -H.

