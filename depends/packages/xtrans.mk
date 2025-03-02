package=xtrans
$(package)_version=1.5.0
$(package)_download_path=https://xorg.freedesktop.org/releases/individual/lib/
$(package)_file_name=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash=1ba4b1a5f2d2f2f58ca3b2d5d599cd73bd00f370b88b6cd998fbd6bc15e576f0
$(package)_dependencies=

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --prefix=$(host_prefix)
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

define $(package)_postprocess_cmds
  rm -f $($(package)_staging_dir)$(host_prefix)/lib/*.la || exit 1
endef
