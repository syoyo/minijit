# note: 3.13 = target_link_directories
cmake_minimum_required(VERSION 3.13)

set(MINIJIT_BUILD_TARGET "minijit")

project(${MINIJIT_BUILD_TARGET} C CXX)

# options
option(MINIJIT_USE_CCACHE "Use ccache for faster recompile." ON)
option(MINIJIT_EXTERNAL_LLVM_PROJECT "Use externally built clang/LLVM(recommended for developers)" ON)
set(MINIJIT_LLVM_PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dist CACHE STRING "Path to built clang/LLVM")
set(MINIJIT_CUSTOM_LINKER "" CACHE STRING "Set custom linker name(e.g. 'lld'). Assume the compiler supports `-fuse=ld=` linker flags.")

# cmake modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/sanitizers)
find_package(Sanitizers) # Address sanitizer (-DSANITIZE_ADDRESS=ON)

# Require strict C++14
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# TODO(LTE): Only enable PIC when compiling python module(dll)?.
set(CMAKE_POSITION_INDEPENDENT_CODE On)

if (MINIJIT_WITH_PYBIND11)
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/third_party/pybind11)
endif (MINIJIT_WITH_PYBIND11)

# [ccache]
if(MINIJIT_USE_CCACHE)
  if(MSVC)
    # No ccache support
  else()
    find_program(CCACHE_EXE ccache)
    if(CCACHE_EXE)

      message(STATUS "Use ccache : " ${CCACHE_EXE})
      # CMAKE_C_COMPILER_LAUNCHER = available from cmake 3.4+)
      if(CMAKE_C_COMPILER_LAUNCHER)
        set(CMAKE_C_COMPILER_LAUNCHER "${CMAKE_C_COMPILER_LAUNCHER}"
                                      "${CCACHE_EXE}")
      else()
        set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_EXE}")
      endif()

      if(CMAKE_CXX_COMPILER_LAUNCHER)
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CMAKE_CXX_COMPILER_LAUNCHER}"
                                        "${CCACHE_EXE}")
      else()
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_EXE}")
      endif()

    endif(CCACHE_EXE)
  endif()
endif()

set(MINIJIT_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cc
    )

if (MINIJIT_EXTERNAL_LLVM_PROJECT)

  set(MINIJIT_LLVM_INCLUDE_DIRS ${MINIJIT_LLVM_PROJECT_DIR}/include)
  set(MINIJIT_CLANG_INCLUDE_DIRS ${MINIJIT_LLVM_PROJECT_DIR}/tools/clang/include)

else (MINIJIT_EXTERNAL_LLVM_PROJECT)

  # [llvm and clang]
  function(add_llvm)
    # ref: https://boxbase.org/entries/2018/jun/11/minimal-llvm-build/
  
    set(LLVM_BUILD_TOOLS OFF CACHE INTERNAL "" FORCE)
    set(LLVM_TARGETS_TO_BUILD "host" CACHE INTERNAL "" FORCE)
    set(LLVM_ENABLE_PROJECTS "clang" CACHE INTERNAL "" FORCE)
    set(LLVM_ENABLE_TERMINFO OFF CACHE INTERNAL "" FORCE) # disable tinfo library
  
    # enable rtti and EH
    set(LLVM_ENABLE_RTTI ON CACHE INTERNAL "" FORCE)
    set(LLVM_ENABLE_EH ON CACHE INTERNAL "" FORCE)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/third_party/llvm-project/llvm EXCLUDE_FROM_ALL)
  
  endfunction()
  
  add_llvm()

  set(MINIJIT_LLVM_INCLUDE_DIRS 
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/llvm-project/llvm/include
  
    # build dir
    ${CMAKE_CURRENT_BINARY_DIR}/third_party/llvm-project/llvm/include
    )
  
  set(MINIJIT_CLANG_INCLUDE_DIRS 
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/llvm-project/clang/include
  
    # build dir
    ${CMAKE_CURRENT_BINARY_DIR}/third_party/llvm-project/llvm/tools/clang/include
    )
endif (MINIJIT_EXTERNAL_LLVM_PROJECT)

add_executable(${MINIJIT_BUILD_TARGET} ${MINIJIT_SOURCES} ${MINIJIT_DEP_SOURCES} ${MINIJIT_GUI_SOURCES})
add_sanitizers(${MINIJIT_BUILD_TARGET})

# custom linker
if( MINIJIT_CUSTOM_LINKER )

  message(STATUS "Use custom linker: " ${MINIJIT_CUSTOM_LINKER})

  # TODO(LTE): Check if `-fuse-ld=` argument is supported on the compiler.
  set_property(TARGET ${MINIJIT_BUILD_TARGET} APPEND_STRING PROPERTY LINK_FLAGS " -fuse-ld=${MINIJIT_CUSTOM_LINKER}")

endif()

target_include_directories(${MINIJIT_BUILD_TARGET} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

set_target_properties(${MINIJIT_BUILD_TARGET}
                      PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

if (WIN32)
  target_link_libraries(${MINIJIT_BUILD_TARGET} PUBLIC advapi32)
endif (WIN32)

if(MINIJIT_WITH_GUI)

  if (WIN32)
    target_link_libraries(${MINIJIT_BUILD_TARGET} PUBLIC shell32 gdi32 ole32)
  endif (WIN32)


  # [imgui]
  target_include_directories(${MINIJIT_BUILD_TARGET}
                             PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/deps/")

  # [glad]
  target_compile_definitions(${MINIJIT_BUILD_TARGET} PRIVATE
                             IMGUI_IMPL_OPENGL_LOADER_GLAD)
  target_include_directories(${MINIJIT_BUILD_TARGET}
                             PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/deps/glad/include")

  target_include_directories(${MINIJIT_BUILD_TARGET}
                             PRIVATE ${glfw_INCLUDE_DIRS})
  list(APPEND MINIJIT_EXT_GUI_LIBRARIES
              glfw
              ${OPENGL_LIBRARIES}
              ${CMAKE_DL_LIBS})
endif(MINIJIT_WITH_GUI)


target_include_directories(${MINIJIT_BUILD_TARGET} PRIVATE ${MINIJIT_LLVM_INCLUDE_DIRS})
target_include_directories(${MINIJIT_BUILD_TARGET} PRIVATE ${MINIJIT_CLANG_INCLUDE_DIRS})

if (MINIJIT_EXTERNAL_LLVM_PROJECT)
  # For libLLVM.so and libclang.so
  target_link_directories(${MINIJIT_BUILD_TARGET} PRIVATE ${MINIJIT_LLVM_PROJECT_DIR}/lib)

  if (WIN32)
    # liblibclang.dll.a
    set(MINIJIT_CLANG_LIB libclang)
  else ()
    # Disable linking both LLVM.so and clang.so due to the following error at runtime.
    # : CommandLine Error: Option 'help-list' registered more than once!
    # LLVM ERROR: inconsistency in registered CommandLine options 

    set(MINIJIT_CLANG_LIB clangAnalysis clangDriver clangEdit clangAST clangASTMatchers clangBasic clangCodeGen clangFrontend clangFrontendTool clangLex clangSema clang clangParse clangTooling clangSerialization)
  endif()

  # use all-in-one libLLVM.so
  set(MINIJIT_LLVM_LIBS LLVM)
  #set(MINIJIT_LLVM_LIBS LLVMAnalysis LLVMScalarOpts LLVMCore LLVMTransformUtils LLVMMCJIT LLVMX86AsmParser LLVMX86AsmPrinter LLVMX86CodeGen LLVMX86Desc LLVMX86Info LLVMX86Utils LLVMAsmPrinter LLVMMC LLVMMCJIT LLVMTarget)
else()
  # Use clang's cmake target
  set(MINIJIT_CLANG_LIB libclang)

  # Use .a's
  set(MINIJIT_LLVM_LIBS LLVMAnalysis LLVMScalarOpts LLVMCore LLVMTransformUtils LLVMMCJIT LLVMX86AsmParser LLVMX86CodeGen LLVMX86Desc LLVMX86Info LLVMMC LLVMTarget)
endif ()

target_link_libraries(${MINIJIT_BUILD_TARGET} PRIVATE ${MINIJIT_LLVM_LIBS})
target_link_libraries(${MINIJIT_BUILD_TARGET} PRIVATE ${MINIJIT_CLANG_LIB})

target_link_libraries(${MINIJIT_BUILD_TARGET} PUBLIC ${MINIJIT_EXT_LIBRARIES} ${CMAKE_DL_LIBS})
target_link_libraries(${MINIJIT_BUILD_TARGET} PRIVATE ${MINIJIT_EXT_GUI_LIBRARIES})

# Increase warning level for clang.
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")

  include(CheckCXXCompilerFlag)

  # -Wno-delete-non-abstract-non-virtual-dtor
  # -Wno-delete-non-virtual-dtor
  #  workaround for pbrtParser https://github.com/ingowald/pbrt-parser/issues/39
  check_cxx_compiler_flag("-Wno-delete-non-abstract-non-virtual-dtor" HAS_NO_DELETE_NON_ABSTRACT_NON_VIRTUAL_DTOR)
  if (HAS_NO_DELETE_NON_ABSTRACT_NON_VIRTUAL_DTOR)
    string(APPEND OPTIONAL_CXX_FLAGS " -Wno-delete-non-abstract-non-virtual-dtor ")
  endif ()

  check_cxx_compiler_flag("-Wno-delete-non-virtual-dtor" HAS_NO_DELETE_NON_VIRTUAL_DTOR)
  if (HAS_NO_DELETE_NON_VIRTUAL_DTOR)
    string(APPEND OPTIONAL_CXX_FLAGS " -Wno-delete-non-virtual-dtor ")
  endif ()

  set(CLANG_COMPILE_FLAGS "-Weverything -Werror -Wno-padded -Wno-c++98-compat-pedantic -Wno-documentation -Wno-documentation-unknown-command -Wno-reserved-id-macro -Wno-unused-variable  -Wno-exit-time-destructors -Wno-global-constructors -Wno-unused-member-function ")

  string(APPEND CLANG_COMPILE_FLAGS ${OPTIONAL_CXX_FLAGS})

  if(MINGW)
    # TODO(LTE): increase warning level for llvm-mingw.
  else()
    set_source_files_properties(
      ${MINIJIT_SOURCES}
      PROPERTIES
      COMPILE_FLAGS
      ${CLANG_COMPILE_FLAGS}
      )
  endif()
endif()

if (MINIJIT_BUILD_TESTS)
  add_subdirectory(tests)
endif (MINIJIT_BUILD_TESTS)

# postbuild
if (WIN32)
  
  # for convienience. uncomment these if it does not work well on your system
  if (MINIJIT_EXTERNAL_LLVM_PROJECT)
    # Copy libclang.dll and libc++.dll
    add_custom_command(TARGET ${MINIJIT_BUILD_TARGET} POST_BUILD        # Adds a post-build event to MyTest
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  # which executes "cmake - E copy_if_different..."
        "${MINIJIT_LLVM_PROJECT_DIR}/bin/libclang.dll"      # src
         $<TARGET_FILE_DIR:${MINIJIT_BUILD_TARGET}>)           # dest

  endif ()
  
  if (LLVM_MINGW_ROOT_ABSPATH)

    # Copy libunwind.dll and libc++.dll
    add_custom_command(TARGET ${MINIJIT_BUILD_TARGET} POST_BUILD        # Adds a post-build event to MyTest
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  # which executes "cmake - E copy_if_different..."
            "${LLVM_MINGW_ROOT_ABSPATH}/x86_64-w64-mingw32/bin/libc++.dll"      # src
            $<TARGET_FILE_DIR:${MINIJIT_BUILD_TARGET}>)           # dest

    add_custom_command(TARGET ${MINIJIT_BUILD_TARGET} POST_BUILD        # Adds a post-build event to MyTest
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  # which executes "cmake - E copy_if_different..."
            "${LLVM_MINGW_ROOT_ABSPATH}/x86_64-w64-mingw32/bin/libunwind.dll"      # src
            $<TARGET_FILE_DIR:${MINIJIT_BUILD_TARGET}>)           # dest

    # TODO(LTE): Copy asan dll only when the app is build with asan support
    add_custom_command(TARGET ${MINIJIT_BUILD_TARGET} POST_BUILD        # Adds a post-build event to MyTest
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  # which executes "cmake - E copy_if_different..."
            "${LLVM_MINGW_ROOT_ABSPATH}/x86_64-w64-mingw32/bin/libclang_rt.asan_dynamic-x86_64.dll"      # src
            $<TARGET_FILE_DIR:${MINIJIT_BUILD_TARGET}>)           # dest

  endif (LLVM_MINGW_ROOT_ABSPATH)

endif (WIN32)

# [VisualStudio]
if(WIN32)
  # Set ${MINIJIT_BUILD_TARGET} as a startup project for VS IDE
  set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${MINIJIT_BUILD_TARGET})

  # For easier debugging in VS IDE(cmake 3.8.0 or later required) Set working
  # directory to ${MINIJIT_BUILD_TARGET} git repo root.
  if(CMAKE_VERSION VERSION_GREATER 3.8.0)
    set_target_properties(${MINIJIT_BUILD_TARGET}
                          PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY
                                     "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()
endif()
