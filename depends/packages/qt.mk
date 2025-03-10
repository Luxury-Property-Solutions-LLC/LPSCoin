package=qt
$(package)_version=5.15.2
$(package)_download_path=https://download.qt.io/archive/qt/5.15/$($(package)_version)/submodules
$(package)_suffix=everywhere-src-$($(package)_version).tar.xz
$(package)_file_name=qtbase-$($(package)_suffix)
$(package)_sha256_hash=3a530d1b243b5dec00bc5493745546874c1c4c246d7bbf02d3e94dcb29a7a546
$(package)_dependencies=openssl freetype fontconfig libxcb libX11 xproto libXext
$(package)_build_subdir=qtbase
$(package)_qt_libs=corelib network widgets gui plugins testlib
$(package)_patches=mac-qmake.conf aarch32-qmake.conf mingw-uuidof.patch pidlist_absolute.patch fix-xcb-include-order.patch fix_qt_pkgconfig.patch

$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=9e6f5f6d0f95a2e9088754e93c9042e28c989e029d0e39f1d95ca1c1e5e39075

$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=9b70411a3c4d6bd2ac87fd48a9df579d7db2e83f0ebfa091df2e0b863ea26feb

$(package)_extra_sources=$($(package)_qttranslations_file_name) $($(package)_qttools_file_name)

define $(package)_set_vars
  $(package)_config_opts_release=-release
  $(package)_config_opts_debug=-debug
  $(package)_config_opts+= -bindir $(build_prefix)/bin
  $(package)_config_opts+= -c++14  # Updated from -c++11 for 5.15
  $(package)_config_opts+= -confirm-license
  $(package)_config_opts+= -dbus-runtime
  $(package)_config_opts+= -hostprefix $(build_prefix)
  $(package)_config_opts+= -no-alsa
  $(package)_config_opts+= -no-audio-backend
  $(package)_config_opts+= -no-cups
  $(package)_config_opts+= -no-egl
  $(package)_config_opts+= -no-eglfs
  $(package)_config_opts+= -no-feature-style-windowsmobile
  $(package)_config_opts+= -no-feature-style-windowsce
  $(package)_config_opts+= -no-gif
  $(package)_config_opts+= -no-glib
  $(package)_config_opts+= -no-gstreamer
  $(package)_config_opts+= -no-icu
  $(package)_config_opts+= -no-iconv
  $(package)_config_opts+= -no-kms
  $(package)_config_opts+= -no-linuxfb
  $(package)_config_opts+= -no-libudev
  $(package)_config_opts+= -no-mitshm
  $(package)_config_opts+= -no-mtdev
  $(package)_config_opts+= -no-nis
  $(package)_config_opts+= -no-pulseaudio
  $(package)_config_opts+= -no-openvg
  $(package)_config_opts+= -no-reduce-relocations
  $(package)_config_opts+= -no-qml-debug
  $(package)_config_opts+= -no-sql-db2
  $(package)_config_opts+= -no-sql-ibase
  $(package)_config_opts+= -no-sql-oci
  $(package)_config_opts+= -no-sql-tds
  $(package)_config_opts+= -no-sql-mysql
  $(package)_config_opts+= -no-sql-odbc
  $(package)_config_opts+= -no-sql-psql
  $(package)_config_opts+= -no-sql-sqlite
  $(package)_config_opts+= -no-sql-sqlite2
  $(package)_config_opts+= -no-use-gold-linker
  $(package)_config_opts+= -no-xinput2
  $(package)_config_opts+= -no-xrender
  $(package)_config_opts+= -nomake examples
  $(package)_config_opts+= -nomake tests
  $(package)_config_opts+= -opensource
  $(package)_config_opts+= -openssl-linked
  $(package)_config_opts+= -optimized-qmake
  $(package)_config_opts+= -pch
  $(package)_config_opts+= -pkg-config
  $(package)_config_opts+= -prefix $(host_prefix)
  $(package)_config_opts+= -qt-libpng
  $(package)_config_opts+= -qt-libjpeg
  $(package)_config_opts+= -qt-pcre
  $(package)_config_opts+= -qt-zlib
  $(package)_config_opts+= -reduce-exports
  $(package)_config_opts+= -static
  $(package)_config_opts+= -silent
  $(package)_config_opts+= -v

  # macOS-specific options (for cross-compilation from non-macOS)
  ifneq ($(build_os),darwin)
    $(package)_config_opts_darwin=-xplatform macx-clang-linux
    $(package)_config_opts_darwin+=-device-option MAC_SDK_PATH=$(OSX_SDK)
    $(package)_config_opts_darwin+=-device-option MAC_SDK_VERSION=$(OSX_SDK_VERSION)
    $(package)_config_opts_darwin+=-device-option CROSS_COMPILE="$(host)-"
    $(package)_config_opts_darwin+=-device-option MAC_MIN_VERSION=$(OSX_MIN_VERSION)
    $(package)_config_opts_darwin+=-device-option MAC_TARGET=$(host)
    $(package)_config_opts_darwin+=-device-option MAC_LD64_VERSION=$(LD64_VERSION)
  endif

  # Linux-specific options
  $(package)_config_opts_linux=-qt-xkbcommon
  $(package)_config_opts_linux+=-qt-xcb
  $(package)_config_opts_linux+=-system-freetype
  $(package)_config_opts_linux+=-no-sm
  $(package)_config_opts_linux+=-fontconfig
  $(package)_config_opts_linux+=-no-opengl

  # Architecture-specific platforms
  $(package)_config_opts_arm_linux=-platform linux-g++ -xplatform $(host)
  $(package)_config_opts_i686_linux=-xplatform linux-g++-32
  $(package)_config_opts_mingw32=-no-opengl -xplatform win32-g++ -device-option CROSS_COMPILE="$(host)-"

  # Build environment
  $(package)_build_env=QT_RCC_TEST=1
endef

define $(package)_fetch_cmds
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_download_file),$($(package)_file_name),$($(package)_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
  $(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash))
endef

define $(package)_extract_cmds
  mkdir -p $($(package)_extract_dir) || exit 1 && \
  echo "$($(package)_sha256_hash)  $($(package)_source)" > $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qttranslations_sha256_hash)  $($(package)_source_dir)/$($(package)_qttranslations_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qttools_sha256_hash)  $($(package)_source_dir)/$($(package)_qttools_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  $(build_SHA256SUM) -c $($(package)_extract_dir)/.$($(package)_file_name).hash || exit 1 && \
  mkdir qtbase || exit 1 && \
  tar --strip-components=1 -xf $($(package)_source) -C qtbase || exit 1 && \
  mkdir qttranslations || exit 1 && \
  tar --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations || exit 1 && \
  mkdir qttools || exit 1 && \
  tar --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools || exit 1
endef

define $(package)_preprocess_cmds
  sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" qttranslations/translations/translations.pro || exit 1 && \
  sed -i.old "s/src_plugins.depends = src_sql src_xml src_network/src_plugins.depends = src_xml src_network/" qtbase/src/src.pro || exit 1 && \
  sed -i.old "s|X11/extensions/XIproto.h|X11/X.h|" qtbase/src/plugins/platforms/xcb/qxcbxsettings.cpp || exit 1 && \
  sed -i.old 's/if \[ "$$$$XPLATFORM_MAC" = "yes" \]; then xspecvals=$$$$(macSDKify/if \[ "$$$$BUILD_ON_MAC" = "yes" \]; then xspecvals=$$$$(macSDKify/' qtbase/configure || exit 1 && \
  mkdir -p qtbase/mkspecs/macx-clang-linux || exit 1 && \
  cp -f qtbase/mkspecs/macx-clang/Info.plist.lib qtbase/mkspecs/macx-clang-linux/ || exit 1 && \
  cp -f qtbase/mkspecs/macx-clang/Info.plist.app qtbase/mkspecs/macx-clang-linux/ || exit 1 && \
  cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/ || exit 1 && \
  cp -f $($(package)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf || exit 1 && \
  mkdir -p qtbase/mkspecs/arm-linux-gnueabihf || exit 1 && \
  cp -f qtbase/mkspecs/linux-arm-gnueabi-g++/qplatformdefs.h qtbase/mkspecs/arm-linux-gnueabihf/ || exit 1 && \
  cp -f $($(package)_patch_dir)/aarch32-qmake.conf qtbase/mkspecs/arm-linux-gnueabihf/qmake.conf || exit 1 && \
  # Test these patches with 5.15.2; some may be obsolete
  patch -p1 < $($(package)_patch_dir)/mingw-uuidof.patch || exit 1 && \
  patch -p1 < $($(package)_patch_dir)/pidlist_absolute.patch || exit 1 && \
  patch -p1 < $($(package)_patch_dir)/fix-xcb-include-order.patch || exit 1 && \
  patch -p1 < $($(package)_patch_dir)/fix_qt_pkgconfig.patch || exit 1 && \
  echo "QMAKE_CFLAGS     += $($(package)_cflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf || exit 1 && \
  echo "QMAKE_CXXFLAGS   += $($(package)_cxxflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf || exit 1 && \
  echo "QMAKE_LFLAGS     += $($(package)_ldflags)" >> qtbase/mkspecs/common/gcc-base.conf || exit 1 && \
  sed -i.old "s|QMAKE_CFLAGS            = |QMAKE_CFLAGS            = $($(package)_cflags) $($(package)_cppflags) |" qtbase/mkspecs/win32-g++/qmake.conf || exit 1 && \
  sed -i.old "s|QMAKE_LFLAGS            = |QMAKE_LFLAGS            = $($(package)_ldflags) |" qtbase/mkspecs/win32-g++/qmake.conf || exit 1 && \
  sed -i.old "s|QMAKE_CXXFLAGS          = |QMAKE_CXXFLAGS            = $($(package)_cxxflags) $($(package)_cppflags) |" qtbase/mkspecs/win32-g++/qmake.conf || exit 1
endef

define $(package)_config_cmds
  export PKG_CONFIG_SYSROOT_DIR=/ && \
  export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig && \
  export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig && \
  ./configure $($(package)_config_opts) || exit 1 && \
  $(MAKE) sub-src-clean || exit 1 && \
  cd ../qttranslations && ../qtbase/bin/qmake qttranslations.pro -o Makefile || exit 1 && \
  cd translations && ../../qtbase/bin/qmake translations.pro -o Makefile || exit 1 && cd ../.. && \
  cd qttools/src/linguist/lrelease/ && ../../../../qtbase/bin/qmake lrelease.pro -o Makefile || exit 1
endef

define $(package)_build_cmds
  $(MAKE) -C src $(addprefix sub-,$($(package)_qt_libs)) || exit 1 && \
  $(MAKE) -C ../qttools/src/linguist/lrelease || exit 1 && \
  $(MAKE) -C ../qttranslations || exit 1
endef

define $(package)_stage_cmds
  $(MAKE) -C src INSTALL_ROOT=$($(package)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) || exit 1 && cd .. && \
  $(MAKE) -C qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target || exit 1 && \
  $(MAKE) -C qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets || exit 1 && \
  if [ -f qtbase/src/plugins/platforms/xcb/xcb-static/libxcb-static.a ]; then \
    cp qtbase/src/plugins/platforms/xcb/xcb-static/libxcb-static.a $($(package)_staging_prefix_dir)/lib || exit 1; \
  fi
endef

define $(package)_postprocess_cmds
  rm -rf $($(package)_staging_dir)$(host_prefix)/{native/mkspecs,native/lib,lib/cmake} || exit 1 && \
  rm -f $($(package)_staging_dir)$(host_prefix)/lib/lib*.la $($(package)_staging_dir)$(host_prefix)/lib/*.prl $($(package)_staging_dir)$(host_prefix)/plugins/*/*.prl || exit 1
endef
