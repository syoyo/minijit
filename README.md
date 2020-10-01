# Minimal clang/llvm jit experience

## Targets

* CUDA(PTX)

## Supported platform

* Linux ubunti 18.04 or 20.04
* Windows 10 64bit
  * [x] MinGW build using llvm-mingw
  * [ ] MSVC or clang-cl build

## Build on Linux

### clang/LLVM build configuratrion

* RTTI and EH(Exception handling) are enabled
  * In LLVM default, RTTI and EH are disabled
* terminfo(for fancy text output for compile message?) is disabled(Linux only)
* MinSizeRel build(to save storage)
* Build shared libraries(libclang.so, libLLVM.so)

### Build libclang/libLLVM as a separate build

I recommend to build libclang and libLLVM as a separated build for developing minijit.

```
$ ./scripts/build-llvm-clang-linux.sh
```

Then Set `MINIJIT_EXTERNAL_LLVM_PROJECT` On for cmake to build minijit.
(Optionally set path to built clang/llvm lib folder with `MINIJIT_LLVM_PROJECT_DIR`

### Monolithic build

Monolithic build is for non-development. For example packaging release build, profiling, and CI build.


Set `MINIJIT_EXTERNAL_LLVM_PROJECT` Off for cmake to build minijit.


## llvm-mingw build

llvm-mingw build(cross compile windows binary on Linux using llvm-mingw https://github.com/mstorsjo/llvm-mingw) is supported.
To cross compile clang/llvm for Windows, native `clang-tblgen` is required but this is not available in common prebuilt binary available from llvm.org, so we build native clang/llvm tools firstly
(Cross compiling llvm/clang at once wont work since unix code path(`LLVM_ON_UNIX`) is detected during the compilation)

### Building native clang/llvm tools

This step is required only one time.

```
$ ./scripts/build-llvm-native-linux.sh
```

llvm/clang native tools are installed into `dist-llvm-native`

#### Cross compiling libclang/libLLVM

With the above clang/llvm native tools, you can now cross-compile libclang/libLLVM for Windows on Linux.

Set path to llvm-mingw to environement variable `LLVM_MINGW_DIR` or edit
`./scripts/build-llvm-llvm-mingw-cross.sh` to set a path to llvm-mingw, then

```
./scripts/build-llvm-llvm-mingw-cross.sh
```

MinGW build of libclang/libLLVM will be installed to `dist-llvm-w64-mingw32/`

## License

MIT license.

### Thrid party licenses

clang/LLVM: Apache License 2.0 with LLVM Exceptions


