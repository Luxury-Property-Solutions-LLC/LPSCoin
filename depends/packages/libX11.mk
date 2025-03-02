package=libX11
$(package)_version:=1.8.7
$(package)_download_path:=http://xorg.freedesktop.org/releases/individual/lib/
$(package)_file_name:=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash:=b289a845c13f09e77d08c51a8bd0bfad25f4b49d38f55447fa9d848862e35be6
$(package)_dependencies:=libxcb xtrans xextproto xproto
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--disable-xkb --disable-shared
  $(package)_config_opts+=--with-libxcb=$($(package)_staging_prefix_dir)
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
