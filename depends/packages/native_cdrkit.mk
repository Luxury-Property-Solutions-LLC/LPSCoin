package=native_cdrkit
$(package)_version=1.1.11
$(package)_download_path=https://distro.ibiblio.org/fatdog/source/600/c
$(package)_file_name=cdrkit-$($(package)_version).tar.bz2
$(package)_sha256_hash=b50d64c214a65b1a79afe3a964c691931a4233e2ba605d793eb85d0ac3652564
$(package)_patches=cdrkit-deterministic.patch

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/cdrkit-deterministic.patch || exit 1
endef

define $(package)_config_cmds
  ./configure --prefix=$(build_prefix) || exit 1
endef

define $(package)_build_cmds
  $(MAKE) genisoimage || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) -C genisoimage install || exit 1
endef

define $(package)_postprocess_cmds
  rm -f $($(package)_staging_dir)$(build_prefix)/bin/{isovfy,isoinfo,isodump,isodebug,devdump} || exit 1
endef
