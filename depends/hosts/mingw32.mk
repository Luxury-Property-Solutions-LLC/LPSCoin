ifeq ($(host_arch),i686)
mingw32_CC := i686-w64-mingw32-gcc
mingw32_CXX := i686-w64-mingw32-g++
else ifeq ($(host_arch),x86_64)
mingw32_CC := x86_64-w64-mingw32-gcc
mingw32_CXX := x86_64-w64-mingw32-g++
endif
