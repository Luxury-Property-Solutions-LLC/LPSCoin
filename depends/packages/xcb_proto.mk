package=xcb_proto
$(package)_version=1.17.0
$(package)_download_path=https://xcb.freedesktop.org/dist
$(package)_file_name=xcb-proto-$($(package)_version).tar.xz
$(package)_sha256_hash=2c8736f97c8e49974431d68c7a3f9d25e04e79e6219d95db2f0a5a089a8e6db2

define $(package)_set_vars
  $(package)_config_opts=--prefix=$(host_prefix)
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
  find $($(package)_staging_dir) -name "*.pyc" -delete || exit 1 && \
  find $($(package)_staging_dir) -name "*.pyo" -delete || exit 1
endef
