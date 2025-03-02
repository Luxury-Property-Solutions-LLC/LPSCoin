package=fontconfig
$(package)_version:=2.15.0
$(package)_download_path:=https://www.freedesktop.org/software/fontconfig/release/
$(package)_file_name:=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash:=6be0ee38f9c24fe225a932e34871992773eeea8e64f2d6d103d37c09de52eb2b
$(package)_dependencies:=freetype expat
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--disable-docs --disable-shared
  $(package)_config_opts+=--with-freetype=$($(package)_staging_prefix_dir)
  $(package)_config_opts+=--with-expat=$($(package)_staging_prefix_dir)
  $(package)_config_opts_linux:=--with-pic
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install || exit 1
endef
