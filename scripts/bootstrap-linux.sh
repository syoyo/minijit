rm -rf build
mkdir build

cmake -G Ninja -DMINIJIT_USE_CCACHE=Off -DCMAKE_BUILD_TYPE=MinSizeRel -Bbuild -H.

