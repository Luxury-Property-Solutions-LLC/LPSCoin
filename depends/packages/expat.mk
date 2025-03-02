package=expat
$(package)_version:=2.6.2
$(package)_download_path:=https://github.com/libexpat/libexpat/releases/download/R_2_6_2
$(package)_file_name:=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash:=c751b75726eddfcf4fa33f165db3a7067d66f3a659ba4a8e8714e5d91e843d12
$(package)_autoconf:=configure

define $(package)_set_vars
  $(package)_config_opts:=--disable-shared
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
