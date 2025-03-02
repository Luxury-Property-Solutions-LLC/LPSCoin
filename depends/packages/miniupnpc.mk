package=miniupnpc
$(package)_version=2.2.8
$(package)_download_path=https://miniupnp.free.fr/files
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=18a865e75d5b0b0b381f8b35dm75e8b11f1fe24f5e4dd684c0ba951f8caeb7f8

define $(package)_set_vars
  $(package)_build_opts=CC="$($(package)_cc)"
  $(package)_build_opts_darwin=OS=Darwin LIBTOOL="$($(package)_libtool)"
  $(package)_build_opts_mingw32=-f Makefile.mingw
  $(package)_build_env+=CFLAGS="$($(package)_cflags) $($(package)_cppflags)" LDFLAGS="$($(package)_ldflags)" AR="$($(package)_ar)"
endef

define $(package)_preprocess_cmds
  sed -e 's|MINIUPNPC_VERSION_STRING \"version\"|MINIUPNPC_VERSION_STRING \"$($(package)_version)\"|' -e 's|OS/version|$(host)|' miniupnpcstrings.h.in > miniupnpcstrings.h && \
  sed -i.old "s|miniupnpcstrings.h: miniupnpcstrings.h.in wingenminiupnpcstrings|miniupnpcstrings.h: miniupnpcstrings.h.in|" Makefile.mingw || exit 1
endef

define $(package)_build_cmds
  $(MAKE) libminiupnpc.a $($(package)_build_opts) || exit 1
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_prefix_dir)/include/miniupnpc $($(package)_staging_prefix_dir)/lib && \
  install -m 644 *.h $($(package)_staging_prefix_dir)/include/miniupnpc && \
  install -m 644 libminiupnpc.a $($(package)_staging_prefix_dir)/lib || exit 1
endef
