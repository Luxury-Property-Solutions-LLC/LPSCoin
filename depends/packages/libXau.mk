package=libXau
$(package)_version:=1.0.11
$(package)_download_path:=http://xorg.freedesktop.org/releases/individual/lib/
$(package)_file_name:=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash:=f3fa3282f526e3252c8452b0d520ed18532be01f4293774cd81a3aa6f8aa5192
$(package)_dependencies:=xproto
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--disable-shared
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
