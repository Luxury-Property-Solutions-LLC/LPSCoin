package=native_protobuf
$(package)_version=3.25.3
$(package)_download_path=https://github.com/protocolbuffers/protobuf/releases/download/v$($(package)_version)
$(package)_file_name=protobuf-$($(package)_version).tar.gz
$(package)_sha256_hash=2e2f0f6b9f3f8f294ba29e44e4c316675ddbff8e5507500c14109c1d8260e4e0

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --prefix=$(build_prefix)
endef

define $(package)_config_cmds
  ./configure $($(package)_config_opts) || exit 1
endef

define $(package)_build_cmds
  $(MAKE) -C src protoc || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) -C src DESTDIR=$($(package)_staging_dir) install-strip || exit 1
endef

define $(package)_postprocess_cmds
  rm -rf $($(package)_staging_dir)$(build_prefix)/{lib,include} || exit 1
endef
