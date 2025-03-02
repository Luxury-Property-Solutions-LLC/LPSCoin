package=protobuf
$(package)_version=$(native_$(package)_version)  # e.g., 3.25.3
$(package)_download_path=$(native_$(package)_download_path)
$(package)_file_name=$(native_$(package)_file_name)
$(package)_sha256_hash=$(native_$(package)_sha256_hash)
$(package)_dependencies=native_$(package)

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --with-protoc=$(build_prefix)/bin/protoc --prefix=$(host_prefix)
  $(package)_config_opts_linux=--with-pic
endef

define $(package)_config_cmds
  ./configure $($(package)_config_opts) || exit 1
endef

define $(package)_build_cmds
  $(MAKE) -C src libprotobuf.la || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) -C src install || exit 1
endef

define $(package)_postprocess_cmds
  rm -f $($(package)_staging_dir)$(host_prefix)/lib/libprotoc.a || exit 1
endef
