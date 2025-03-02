# Linux-specific build tools
build_linux_CC := gcc
build_linux_CXX := g++
build_linux_AR := ar
build_linux_RANLIB := ranlib
build_linux_STRIP := strip
build_linux_NM := nm
build_linux_SHA256SUM := sha256sum
build_linux_DOWNLOAD := curl --location --fail --connect-timeout $(DOWNLOAD_CONNECT_TIMEOUT) --retry $(DOWNLOAD_RETRIES) -o "$@"
