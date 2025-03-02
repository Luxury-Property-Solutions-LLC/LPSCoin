package=openssl
$(package)_version=1.1.1w
$(package)_download_path=https://www.openssl.org/source
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d9077bfa037b993

define $(package)_set_vars
  $(package)_config_env=AR="$($(package)_ar)" RANLIB="$($(package)_ranlib)" CC="$($(package)_cc)"
  $(package)_config_opts=--prefix=$(host_prefix) --openssldir=$(host_prefix)/etc/openssl
  $(package)_config_opts+=no-camellia no-capieng no-cast no-comp no-dso no-dtls1
  $(package)_config_opts+=no-ec_nistp_64_gcc_128 no-gost no-gmp no-heartbeats no-idea
  $(package)_config_opts+=no-jpake no-krb5 no-libunbound no-md2 no-mdc2 no-rc4
  $(package)_config_opts+=no-rc5 no-rdrand no-rfc3779 no-rsax no-sctp no-seed
  $(package)_config_opts+=no-sha0 no-shared no-ssl-trace no-static_engine no-store
  $(package)_config_opts+=no-unit-test no-weak-ssl-ciphers no-whirlpool no-zlib
  $(package)_config_opts+=no-zlib-dynamic $($(package)_cflags) $($(package)_cppflags)
  $(package)_config_opts_linux=-fPIC -Wa,--noexecstack
  $(package)_config_opts_x86_64_linux=linux-x86_64
  $(package)_config_opts_i686_linux=linux-elf
  $(package)_config_opts_arm_linux=linux-armv4
  $(package)_config_opts_aarch64_linux=linux-aarch64
  $(package)_config_opts_mipsel_linux=linux-mips32
  $(package)_config_opts_mips_linux=linux-mips32
  $(package)_config_opts_powerpc_linux=linux-ppc
  $(package)_config_opts_x86_64_darwin=darwin64-x86_64-cc
  $(package)_config_opts_x86_64_mingw32=mingw64
  $(package)_config_opts_i686_mingw32=mingw
endef

define $(package)_preprocess_cmds
  sed -i.old "/define DATE/d" util/mkbuildinf.pl || exit 1 && \
  sed -i.old "s|engines apps test|engines|" Makefile.org || exit 1
endef

define $(package)_config_cmds
  ./Configure $($(package)_config_opts) || exit 1
endef

define $(package)_build_cmds
  $(MAKE) -j1 build_libs libcrypto.pc libssl.pc openssl.pc || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) INSTALL_PREFIX=$($(package)_staging_dir) -j1 install_sw || exit 1
endef

define $(package)_postprocess_cmds
  rm -rf $($(package)_staging_dir)$(host_prefix)/{share,bin,etc} || exit 1
endef
