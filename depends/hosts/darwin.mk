# Minimum macOS version and SDK settings
OSX_MIN_VERSION := 10.15  # Update to a more recent minimum (e.g., Catalina)
OSX_SDK_VERSION := 14.0   # Match a modern Xcode SDK
OSX_SDK ?= $(SDK_PATH)/MacOSX$(OSX_SDK_VERSION).sdk
SDK_PATH ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs

# Linker version (updated if targeting newer SDK)
LD64_VERSION := 609  # Matches Xcode 12+ for macOS 11+

# Compilers with architecture fallback
darwin_CC := clang -target $(host) -mmacosx-version-min=$(OSX_MIN_VERSION) --sysroot $(OSX_SDK) -mlinker-version=$(LD64_VERSION)
darwin_CXX := clang++ -target $(host) -mmacosx-version-min=$(OSX_MIN_VERSION) --sysroot $(OSX_SDK) -mlinker-version=$(LD64_VERSION) -stdlib=libc++

# Enhanced base flags
darwin_CFLAGS := -pipe -Wall -Wextra
darwin_CXXFLAGS := $(darwin_CFLAGS) -std=c++11  # Specify C++ standard if needed

# Release and debug flags
darwin_release_CFLAGS := -O2
darwin_release_CXXFLAGS := $(darwin_release_CFLAGS)
darwin_debug_CFLAGS := -O1 -g  # Add -g for debugging symbols
darwin_debug_CXXFLAGS := $(darwin_debug_CFLAGS)

# Native toolchain
darwin_native_toolchain := native_cctools
