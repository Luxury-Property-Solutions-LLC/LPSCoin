# Core dependencies for all platforms
packages:=boost openssl libevent zeromq

# Platform-specific additions (if any)
darwin_packages:=
linux_packages:=

# Native build tools
native_packages:=native_ccache

# Qt-related native tools
qt_native_packages:=native_protobuf

# Qt dependencies (common across platforms where applicable)
qt_packages:=qrencode protobuf zlib

# Qt dependencies for Linux (x86_64 and i686)
qt_x86_64_linux_packages:=qt expat dbus libxcb xcb_proto libXau xproto freetype fontconfig libX11 xextproto libXext xtrans
qt_i686_linux_packages:=$(qt_x86_64_linux_packages)

# Qt for macOS (assumes dependencies bundled)
qt_darwin_packages:=qt

# Qt for Windows (MinGW)
qt_mingw32_packages:=qt

# Wallet backend
wallet_packages:=bdb

# UPnP support
upnp_packages:=miniupnpc

# macOS-specific native tools
darwin_native_packages:=native_biplist native_ds_store native_mac_alias

# Additional tools for non-macOS builds to support macOS targets
ifneq ($(build_os),darwin)
darwin_native_packages+=native_cctools native_cdrkit native_libdmg-hfsplus
endif
