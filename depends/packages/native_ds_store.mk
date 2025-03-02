package=native_ds_store
$(package)_version=1.3.0
$(package)_download_path=https://github.com/al45tair/ds_store/archive/refs/tags/
$(package)_download_file=v$($(package)_version).tar.gz
$(package)_file_name=ds_store-$($(package)_version).tar.gz
$(package)_sha256_hash=628f74a398c59e2d97e8cc2fb076c87e1bf4ff0b8f4ba90f6a18b6c4815f9872
$(package)_install_libdir=$(build_prefix)/lib/python3/dist-packages
$(package)_dependencies=native_biplist

define $(package)_build_cmds
  python3 setup.py build || exit 1
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_install_libdir) || exit 1 && \
  python3 setup.py install --root=$($(package)_staging_dir) --prefix=$(build_prefix) --install-lib=$($(package)_install_libdir) || exit 1
endef
