package=libevent
$(package)_version=2.1.12-stable
$(package)_download_path=https://github.com/libevent/libevent/archive/
$(package)_file_name=release-$($(package)_version).tar.gz
$(package)_sha256_hash=92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb

define $(package)_preprocess_cmds
  ./autogen.sh || exit 1
endef

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --disable-openssl --disable-libevent-regress --disable-samples --prefix=$($(package)_staging_prefix_dir)
  $(package)_config_opts_release=--disable-debug-mode
  $(package)_config_opts_linux=--with-pic
endef

define $(package)_config_cmds
  ./configure $($(package)_config_opts) || exit 1
endef

define $(package)_build_cmds
  $(MAKE) || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install || exit 1
endef
