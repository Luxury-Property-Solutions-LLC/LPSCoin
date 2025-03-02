package=native_libdmg-hfsplus
$(package)_version=0.1
$(package)_download_path=https://github.com/theuni/libdmg-hfsplus/archive
$(package)_file_name=libdmg-hfsplus-v$($(package)_version).tar.gz
$(package)_sha256_hash=6569a02eb31c2827080d7d59001869ea14484c281efab0ae7f2b86af5c3120b3
$(package)_build_subdir=build

define $(package)_preprocess_cmds
endef

define $(package)_config_cmds
  cmake -DCMAKE_INSTALL_PREFIX=$(build_prefix) .. || exit 1
endef

define $(package)_build_cmds
  $(MAKE) -C dmg || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) -C dmg install || exit 1
endef
