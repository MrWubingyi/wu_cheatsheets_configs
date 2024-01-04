# set(CMAKE_VERBOSE_MAKEFILE on)
set(warn_flags " -Wall -Wextra                  \
                -Wno-missing-field-initializers \
                -Wno-unused-parameter           \
                -Wno-unused-variable            \
                -Wno-unused-function            \
                -Wno-unused-but-set-variable    \
                -Wno-cast-qual")                # 暂不使用 -Waddress-of-packed-member 打包成员地址

if (GCC_VERSION VERSION_GREATER 7)
	  # gcc 版本大于 7.0 的编译参数
	  set(warn_flags "-Wno-format-truncation      \
                    -Wno-address-of-packed-member")
else()
	  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif()

set(CMAKE_C_FLAGS "-D_GNU_SOURCE -std=c11 -m64  ${CMAKE_C_FLAGS}  ${warn_flags} -fdiagnostics-color=always")
set(CMAKE_CXX_FLAGS "-D_GNU_SOURCE -m64 ${CMAKE_CXX_FLAGS}  ${warn_flags}")
# set(CMAKE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}  -fsanitize=address")
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fsanitize=leak")
# set(ASAN_FLAGS "-fno-omit-frame-pointer -fsanitize=address")
# set(CMAKE_EXE_LINKER_FLAGS_ASAN "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libasan")

set(CMAKE_CXX_STANDARD 11)
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:/usr/local/lib64/pkgconfig")

find_package(PkgConfig REQUIRED)

pkg_search_module(yaEnginew REQUIRED libyaEnginew)
pkg_check_modules(YA_EMAIL REQUIRED IMPORTED_TARGET libyaemail)
# pkg_check_modules(yaSdxWatch REQUIRED IMPORTED_TARGET libyaSdxWatch)
# pkg_check_modules(yv_sub REQUIRED IMPORTED_TARGET libyv_sub)
# pkg_check_modules(yaEnginew REQUIRED IMPORTED_TARGET libyaEnginew)
# pkg_check_modules(YA_PROTO_RECORD REQUIRED IMPORTED_TARGET libyaProtoRecord)
# pkg_check_modules(YA_FTYPES REQUIRED IMPORTED_TARGET libyaFtypes)
list(APPEND pkg_libaries
  ${yaSdxWatch_LIBRARIES}
  ${yv_sub_STATIC_LDFLAGS}
  ${yaEnginew_STATIC_LDFLAGS}
  # ${yaemail_STATIC_LDFLAGS}
  # add libyaemail
  PkgConfig::YA_EMAIL
)

list(APPEND pkg_include
  ${yaSdxWatch_LIBRARIES}
)

find_library(dpdk_libaries dpdk)

include_directories(
  /usr/local/include/dpdk
  /usr/include/dpdk
  ${CMAKE_SOURCE_DIR}/include
  ${CMAKE_SOURCE_DIR}/src
  ${CMAKE_SOURCE_DIR}/src/framework
  /usr/include/glib-2.0
  /usr/include
  /usr/lib64/glib-2.0/include
)

add_compile_options("${dpdk_cflags}")

add_subdirectory(framework)


add_executable(${AppName}
  main.c
  $<TARGET_OBJECTS:framework>
)

target_link_directories(${AppName} PRIVATE
  ${CMAKE_SOURCE_DIR}/lib
)

target_link_libraries(${AppName}
  -Wl,--whole-archive,${dpdk_libaries},--no-whole-archive
  ${pkg_libaries}
  yarestful
  yaemail
  # vmime
  # icuuc
  # anl
  # -l:libasan.a
  glib-2.0
  ssl
  crypto
  maxminddb
  z
  cjson
  iniparser
  rdkafka
  jsoncpp
  curl
  microxml
  dl
  zlog
  numa
  pcap
  # -static-libasan
  # -fsanitize=address
  pthread
  rt
  PkgConfig::YA_PROTO_RECORD
  PkgConfig::YA_FTYPES
)

set_target_properties(${AppName} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/run)

# 为可执行文件生成软链接
add_custom_command(TARGET ${AppName} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E create_symlink $<TARGET_FILE:${AppName}> ${CMAKE_SOURCE_DIR}/run/yaDpi
)

add_custom_target(vtysh
  COMMAND
    make -C ${CMAKE_SOURCE_DIR}/vtysh
)

message("begin dpi_files = ${dpi_files}")
message("begin dpi_dirs = ${dpi_dirs}")

list(APPEND dpi_files
  ${CMAKE_SOURCE_DIR}/etc/config.ini
  ${CMAKE_SOURCE_DIR}/run/start.sh
  ${CMAKE_SOURCE_DIR}/run/manuf
)

list(APPEND dpi_bins
  ${CMAKE_SOURCE_DIR}/run/start.sh
  ${CMAKE_SOURCE_DIR}/scripts/mount.sh
  ${CMAKE_SOURCE_DIR}/run/vtysh
)

list(APPEND dpi_dirs
  # ${CMAKE_SOURCE_DIR}/json_fields  //老的映射表不打包
  ${CMAKE_SOURCE_DIR}/field
)
include(${CMAKE_SOURCE_DIR}/cmake/Install.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/CPack.cmake)
