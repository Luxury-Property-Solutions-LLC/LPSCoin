package=dbus
$(package)_version:=1.14.10
$(package)_download_path:=https://dbus.freedesktop.org/releases/dbus
$(package)_file_name:=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash:=ba1b02f5586cef279686964bb0fe35a270e91e9d928d87d21a6a7d95625caaec
$(package)_dependencies:=expat
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--disable-tests --disable-doxygen-docs --disable-xml-docs --disable-shared --without-x
  $(package)_config_opts+=--with-expat=$($(package)_staging_prefix_dir)
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) -C dbus libdbus-1.la || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) -C dbus DESTDIR=$($(package)_staging_dir) install-libLTLIBRARIES install-dbusincludeHEADERS install-nodist_dbusarchincludeHEADERS || exit 1 && \
  $(MAKE) DESTDIR=$($(package)_staging_dir) install-pkgconfigDATA || exit 1
endef
