# Minimal clang/llvm jit experience

## Targets

* CUDA(PTX) 

## Build

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

## License

MIT license.

### Thrid party licenses

clang/LLVM: Apache License 2.0 with LLVM Exceptions 


