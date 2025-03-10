package=boost
$(package)_version:=1_84_0
$(package)_download_path:=https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source
$(package)_file_name:=$(package)_$($(package)_version).tar.bz2
$(package)_sha256_hash:=cc4b893acf2557060ea240c37e66ea1d939ed0a6ae1f08b63d831dc3287589e6

define $(package)_set_vars
  $(package)_config_opts_release:=variant=release
  $(package)_config_opts_debug:=variant=debug
  $(package)_config_opts:=--layout=tagged --build-type=complete --user-config=user-config.jam
  $(package)_config_opts+=threading=multi link=static -sNO_BZIP2=1 -sNO_ZLIB=1 runtime-link=static
  $(package)_config_opts_linux:=threadapi=pthread
  $(package)_config_opts_darwin:=--toolset=clang
  $(package)_config_opts_mingw32:=binary-format=pe target-os=windows threadapi=win32
  $(package)_config_opts_x86_64_mingw32:=address-model=64
  $(package)_config_opts_i686_mingw32:=address-model=32
  $(package)_config_opts_i686_linux:=address-model=32 architecture=x86
  $(package)_toolset_$(host_os):=gcc
  $(package)_archiver_$(host_os):=$($(package)_ar)
  $(package)_toolset_darwin:=clang
  $(package)_archiver_darwin:=$($(package)_libtool)
  $(package)_config_libraries:=chrono,filesystem,program_options,system,thread,test
  $(package)_cxxflags:=-std=c++11 -fvisibility=hidden
  $(package)_cxxflags_linux:=-fPIC
endef

define $(package)_preprocess_cmds
  echo "using $($(package)_toolset_$(host_os)) : : $($(package)_cxx) : <cxxflags>\"$($(package)_cxxflags) $($(package)_cppflags)\" <linkflags>\"$($(package)_ldflags)\" <archiver>\"$($(package)_archiver_$(host_os))\" <striper>\"$(host_STRIP)\" <ranlib>\"$(host_RANLIB)\" <rc>\"$(host_WINDRES)\" : ;" > user-config.jam || exit 1
endef

define $(package)_config_cmds
  ./bootstrap.sh --without-icu --with-libraries=$($(package)_config_libraries)
endef

define $(package)_build_cmds
  ./b2 -d2 -j2 -d1 --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) stage
endef

define $(package)_stage_cmds
  ./b2 -d0 -j4 --prefix=$($(package)_staging_prefix_dir) $($(package)_config_opts) install
endef
