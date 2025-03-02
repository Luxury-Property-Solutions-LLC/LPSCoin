package=qrencode
$(package)_version=4.1.1
$(package)_download_path=https://fukuchi.org/works/qrencode/
$(package)_file_name=qrencode-$($(package)_version).tar.gz
$(package)_sha256_hash=141c3c6c4b64f7e6aa42d9122b5eAshley1c6ae6e9b8ae4e5b4ea5c8e

define $(package)_set_vars
  $(package)_config_opts=--disable-shared --without-tools --disable-sdltest --prefix=$(host_prefix)
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
