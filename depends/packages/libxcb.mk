package=libxcb
$(package)_version=1.17.0
$(package)_download_path=https://xcb.freedesktop.org/dist
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=5e2c236bba3e2e7bc4eaee5456de5c8f8f3ab411c0ab5e3a18dad4bbb6d4db8b
$(package)_dependencies=xcb_proto libXau xproto

define $(package)_set_vars
  $(package)_config_opts=--disable-static --prefix=$($(package)_staging_prefix_dir)
endef

define $(package)_preprocess_cmds
  sed "s/pthread-stubs//" -i configure || exit 1
endef

# Don't install xcb headers to the default path to work around a Qt build issue:
# https://bugreports.qt.io/browse/QTBUG-34748
define $(package)_config_cmds
  ./configure $($(package)_config_opts) --includedir=$(host_prefix)/include/xcb-shared || exit 1
endef

define $(package)_build_cmds
  $(MAKE) || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install || exit 1
endef

define $(package)_postprocess_cmds
  rm -rf share/man share/doc || exit 1
endef
