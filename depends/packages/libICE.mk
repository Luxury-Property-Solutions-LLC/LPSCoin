package=freetype
$(package)_version:=2.13.2
$(package)_download_path:=https://download.savannah.gnu.org/releases/$(package)
$(package)_file_name:=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash:=12991c4e55c506dd7f9b765933e62fd2be2e06d7549550f66c1361b24e4fd832
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--without-zlib --without-png --disable-shared
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
