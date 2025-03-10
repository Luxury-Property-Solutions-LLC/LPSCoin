# Base compiler flags for Linux
linux_CFLAGS := -pipe
linux_CXXFLAGS += $(linux_CFLAGS)

# Release build flags
linux_release_CFLAGS := -O2
linux_release_CXXFLAGS += $(linux_release_CFLAGS)

# Debug build flags
linux_debug_CFLAGS := -O1
linux_debug_CXXFLAGS += $(linux_debug_CFLAGS)
linux_debug_CPPFLAGS := -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC

# Architecture-specific tools (assuming host_arch, not build_arch)
ifeq ($(host_arch),i686)
i686_linux_CC := gcc -m32
i686_linux_CXX := g++ -m32
i686_linux_AR := ar
i686_linux_RANLIB := ranlib
i686_linux_NM := nm
i686_linux_STRIP := strip
else ifeq ($(host_arch),x86_64)
x86_64_linux_CC := gcc -m64
x86_64_linux_CXX := g++ -m64
x86_64_linux_AR := ar
x86_64_linux_RANLIB := ranlib
x86_64_linux_NM := nm
x86_64_linux_STRIP := strip
else
# Fallback for other architectures (e.g., arm, aarch64)
i686_linux_CC := $(default_host_CC) -m32
i686_linux_CXX := $(default_host_CXX) -m32
i686_linux_AR := $(default_host_AR)
i686_linux_RANLIB := $(default_host_RANLIB)
i686_linux_NM := $(default_host_NM)
i686_linux_STRIP := $(default_host_STRIP)
x86_64_linux_CC := $(default_host_CC) -m64
x86_64_linux_CXX := $(default_host_CXX) -m64
x86_64_linux_AR := $(default_host_AR)
x86_64_linux_RANLIB := $(default_host_RANLIB)
x86_64_linux_NM := $(default_host_NM)
x86_64_linux_STRIP := $(default_host_STRIP)
endif
