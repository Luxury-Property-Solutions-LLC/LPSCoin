package=zeromq
$(package)_version=4.3.5
$(package)_download_path=https://github.com/zeromq/libzmq/releases/download/v$($(package)_version)/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=6653d62b9265f5a6ce71d0416cfb8a92d683e72093a7013a8f50b2a0f24e64b9

define $(package)_set_vars
  $(package)_config_opts=--without-documentation --disable-shared --without-libsodium --prefix=$(host_prefix)
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
  rm -rf $($(package)_staging_dir)$(host_prefix)/{bin,share} || exit 1
endef
