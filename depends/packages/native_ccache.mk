package=native_ccache
$(package)_version=4.10.2
$(package)_download_path=https://download.samba.org/pub/ccache/
$(package)_file_name=ccache-$($(package)_version).tar.xz
$(package)_sha256_hash=4db23e3d6c7d13e2c32c392aacdd7c6b295cdca69128616bd9e0b2a7ae4127d8

define $(package)_set_vars
  $(package)_config_opts=--prefix=$($(package)_staging_prefix_dir)
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
  rm -rf lib include || exit 1
endef
