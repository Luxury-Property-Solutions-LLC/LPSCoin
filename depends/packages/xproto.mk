package=xproto
$(package)_version=7.0.31
$(package)_download_path=https://xorg.freedesktop.org/releases/individual/proto
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=6d755eaae27b45c5cc75529a12855fedf3677f97c5a49bfc5ae5eba8ecf4f8ab

define $(package)_set_vars
  $(package)_config_opts=--prefix=$(host_prefix)
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
