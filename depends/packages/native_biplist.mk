package=native_biplist
$(package)_version=1.0.3
$(package)_download_path=https://files.pythonhosted.org/packages/source/b/biplist/
$(package)_file_name=biplist-$($(package)_version).tar.gz
$(package)_sha256_hash=ec7e4f7df0d0c71b00ed9a7574866518e93d31c1b3170e8a7c9cf442c369b0f6
$(package)_install_libdir=$(build_prefix)/lib/python3/dist-packages

define $(package)_build_cmds
  python3 setup.py build || exit 1
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_install_libdir) && \
  python3 setup.py install --root=$($(package)_staging_dir) --prefix=$(build_prefix) --install-lib=$($(package)_install_libdir) || exit 1
endef
