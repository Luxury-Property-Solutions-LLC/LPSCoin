package=libXext
$(package)_version=1.3.6
$(package)_download_path=https://xorg.freedesktop.org/archive/individual/lib/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=1d7a9ba3640f843fe1bb15b80fb3902f30eb9f2e6e7fc7b5f1e0f6cd5f87c307
$(package)_dependencies=xproto xextproto libX11 libXau

define $(package)_set_vars
  $(package)_config_opts=--disable-static --prefix=$($(package)_staging_prefix_dir)
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
