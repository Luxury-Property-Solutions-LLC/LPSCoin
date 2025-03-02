.NOTPARALLEL:

# Base paths for sources, cache, and SDKs
SOURCES_PATH ?= $(BASEDIR)/sources
BASE_CACHE ?= $(BASEDIR)/built
SDK_PATH ?= $(BASEDIR)/SDKs
NO_QT ?=
NO_WALLET ?=
NO_UPNP ?=
FALLBACK_DOWNLOAD_PATH ?= https://bitcoincore.org/depends-sources

# Build and host configuration
BUILD = $(shell ./config.guess)
HOST ?= $(BUILD)
PATCHES_PATH = $(BASEDIR)/patches
BASEDIR = $(CURDIR)
HASH_LENGTH := 11
DOWNLOAD_CONNECT_TIMEOUT := 30  # Increased for reliability
DOWNLOAD_RETRIES := 3
HOST_ID_SALT ?= host-salt-$(HOST)
BUILD_ID_SALT ?= build-salt-$(BUILD)

host := $(BUILD)
ifneq ($(HOST),)
host := $(HOST)
host_toolchain := $(HOST)-
endif

# Release type (debug or release)
ifneq ($(DEBUG),)
release_type = debug
else
release_type = release
endif

# Directory setup
base_build_dir = $(BASEDIR)/work/build
base_staging_dir = $(BASEDIR)/work/staging
base_download_dir = $(BASEDIR)/work/download
canonical_host := $(shell ./config.sub $(HOST))
build := $(shell ./config.sub $(BUILD))

# Architecture and OS detection
build_arch = $(firstword $(subst -, ,$(build)))
build_vendor = $(word 2,$(subst -, ,$(build)))
full_build_os := $(subst $(build_arch)-$(build_vendor)-,,$(build))
build_os := $(findstring linux,$(full_build_os))
build_os += $(findstring darwin,$(full_build_os))
build_os := $(strip $(build_os))
ifeq ($(build_os),)
build_os = $(full_build_os)
endif

host_arch = $(firstword $(subst -, ,$(canonical_host)))
host_vendor = $(word 2,$(subst -, ,$(canonical_host)))
full_host_os := $(subst $(host_arch)-$(host_vendor)-,,$(canonical_host))
host_os := $(findstring linux,$(full_host_os))
host_os += $(findstring darwin,$(full_host_os))
host_os += $(findstring mingw32,$(full_host_os))
host_os := $(strip $(host_os))
ifeq ($(host_os),)
host_os = $(full_host_os)
endif

$(host_arch)_$(host_os)_prefix = $(BASEDIR)/$(host)
$(host_arch)_$(host_os)_host = $(host)
host_prefix = $($(host_arch)_$(host_os)_prefix)
build_prefix = $(host_prefix)/native
build_host = $(build)

# Verbosity control
AT_$(V) :=
AT_ := @
AT := $(AT_$(V))

# Default target: install all dependencies
all: install

# Include configuration files
include hosts/$(host_os).mk
include hosts/default.mk
include builders/$(build_os).mk
include builders/default.mk
include packages/packages.mk

# Build and host ID strings for cache validation
build_id_string := $(BUILD_ID_SALT)
build_id_string += $(shell $(build_CC) --version 2>/dev/null)
build_id_string += $(shell $(build_AR) --version 2>/dev/null)
build_id_string += $(shell $(build_CXX) --version 2>/dev/null)
build_id_string += $(shell $(build_RANLIB) --version 2>/dev/null)
build_id_string += $(shell $(build_STRIP) --version 2>/dev/null)

$(host_arch)_$(host_os)_id_string := $(HOST_ID_SALT)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CC) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_AR) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_CXX) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_RANLIB) --version 2>/dev/null)
$(host_arch)_$(host_os)_id_string += $(shell $(host_STRIP) --version 2>/dev/null)

# Conditional package inclusion
qt_packages_$(NO_QT) = $(qt_packages) $(qt_$(host_os)_packages) $(qt_$(host_arch)_$(host_os)_packages)
wallet_packages_$(NO_WALLET) = $(wallet_packages)
upnp_packages_$(NO_UPNP) = $(upnp_packages)

# Combine all packages
packages += $($(host_arch)_$(host_os)_packages) $($(host_os)_packages) $(qt_packages_) $(wallet_packages_) $(upnp_packages_)
native_packages += $($(host_arch)_$(host_os)_native_packages) $($(host_os)_native_packages)

# Include Qt native packages if Qt is enabled
ifneq ($(qt_packages_),)
native_packages += $(qt_native_packages)
endif

all_packages = $(packages) $(native_packages)

meta_depends = Makefile funcs.mk builders/default.mk hosts/default.mk hosts/$(host_os).mk builders/$(build_os).mk

$(host_arch)_$(host_os)_native_toolchain ?= $($(host_os)_native_toolchain)

include funcs.mk

toolchain_path = $($($(host_arch)_$(host_os)_native_toolchain)_prefixbin)
final_build_id_long += $(shell $(build_SHA256SUM) config.site.in)
final_build_id += $(shell echo -n "$(final_build_id_long)" | $(build_SHA256SUM) | cut -c-$(HASH_LENGTH))

# Main installation target
$(host_prefix)/.stamp_$(final_build_id): $(native_packages) $(packages)
	$(AT)rm -rf $(@D) || exit 1
	$(AT)mkdir -p $(@D) || exit 1
	$(AT)echo "Copying packages: $^"
	$(AT)echo "To: $(@D)"
	$(AT)cd $(@D) && $(foreach package,$^, tar xf $($(package)_cached) || exit 1;)
	$(AT)touch $@ || exit 1

# Generate config.site
$(host_prefix)/share/config.site: config.site.in $(host_prefix)/.stamp_$(final_build_id)
	$(AT)mkdir -p $(@D) || exit 1
	$(AT)sed -e 's|@HOST@|$(host)|' \
            -e 's|@CC@|$(toolchain_path)$(host_CC)|' \
            -e 's|@CXX@|$(toolchain_path)$(host_CXX)|' \
            -e 's|@AR@|$(toolchain_path)$(host_AR)|' \
            -e 's|@RANLIB@|$(toolchain_path)$(host_RANLIB)|' \
            -e 's|@NM@|$(toolchain_path)$(host_NM)|' \
            -e 's|@STRIP@|$(toolchain_path)$(host_STRIP)|' \
            -e 's|@build_os@|$(build_os)|' \
            -e 's|@host_os@|$(host_os)|' \
            -e 's|@CFLAGS@|$(strip $(host_CFLAGS) $(host_$(release_type)_CFLAGS))|' \
            -e 's|@CXXFLAGS@|$(strip $(host_CXXFLAGS) $(host_$(release_type)_CXXFLAGS))|' \
            -e 's|@CPPFLAGS@|$(strip $(host_CPPFLAGS) $(host_$(release_type)_CPPFLAGS))|' \
            -e 's|@LDFLAGS@|$(strip $(host_LDFLAGS) $(host_$(release_type)_LDFLAGS))|' \
            -e 's|@no_qt@|$(NO_QT)|' \
            -e 's|@no_wallet@|$(NO_WALLET)|' \
            -e 's|@no_upnp@|$(NO_UPNP)|' \
            -e 's|@debug@|$(DEBUG)|' \
            $< > $@ || exit 1
	$(AT)touch $@ || exit 1

# Checksum verification for cached builds
define check_or_remove_cached
	$(AT)echo "Checking $(package) cached checksum..." && \
	mkdir -p $(BASE_CACHE)/$(host)/$(package) || exit 1 && cd $(BASE_CACHE)/$(host)/$(package) && \
	$(build_SHA256SUM) -c $($(package)_cached_checksum) >/dev/null 2>/dev/null || \
	( rm -f $($(package)_cached_checksum) && \
	  if test -f "$($(package)_cached)"; then echo "Checksum mismatch for $(package). Forcing rebuild.."; rm -f $($(package)_cached_checksum) $($(package)_cached); fi )
endef

# Checksum verification for sources
define check_or_remove_sources
	$(AT)echo "Checking $(package) source checksum..." && \
	mkdir -p $($(package)_source_dir) || exit 1 && cd $($(package)_source_dir) && \
	test -f $($(package)_fetched) && ( $(build_SHA256SUM) -c $($(package)_fetched) >/dev/null 2>/dev/null || \
	( echo "Checksum missing or mismatched for $(package) source. Forcing re-download."; \
	  rm -f $($(package)_all_sources) $($(package)_fetched))) || true
endef

# Targets for checking packages and sources
check-packages:
	@$(foreach package,$(all_packages),$(call check_or_remove_cached,$(package));)

check-sources:
	@$(foreach package,$(all_packages),$(call check_or_remove_sources,$(package));)

$(host_prefix)/share/config.site: check-packages

check-packages: check-sources

# Install target
install: check-packages $(host_prefix)/share/config.site

# Download targets
download-one: check-sources $(all_sources)

download-osx:
	@$(MAKE) -s HOST=x86_64-apple-darwin11 download-one

download-linux:
	@$(MAKE) -s HOST=x86_64-unknown-linux-gnu download-one

download-win:
	@$(MAKE) -s HOST=x86_64-w64-mingw32 download-one

download: download-osx download-linux download-win

# Phony targets
.PHONY: all install check-packages check-sources download-one download-osx download-linux download-win download
