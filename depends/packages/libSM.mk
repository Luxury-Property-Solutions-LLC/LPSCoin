package=libSM
$(package)_version:=1.2.4
$(package)_download_path:=http://xorg.freedesktop.org/releases/individual/lib/
$(package)_file_name:=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash:=fdcbe51e861d205689d1e1848a4755dba4a2713da7a5358c5c8d301df705537b
$(package)_dependencies:=xtrans xproto libICE
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--without-libuuid --without-xsltproc --disable-docs --disable-shared
  $(package)_config_opts+=--with-libice=$($(package)_staging_prefix_dir)
  $(package)_config_opts_linux:=--with-pic
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install || exit 1
endef
