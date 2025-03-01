# Require Autoconf 2.60 or newer for AS_ECHO/AS_ECHO_N
AC_PREREQ([2.60])

# Define version and metadata as m4 constants
m4_define([CLIENT_VERSION_MAJOR], [4])
m4_define([CLIENT_VERSION_MINOR], [1])
m4_define([CLIENT_VERSION_REVISION], [0])
m4_define([CLIENT_VERSION_BUILD], [0])
m4_define([CLIENT_VERSION_IS_RELEASE], [true])
m4_define([COPYRIGHT_YEAR], [2022])
m4_define([CLIENT_VERSION], [CLIENT_VERSION_MAJOR.CLIENT_VERSION_MINOR.CLIENT_VERSION_REVISION])

# Initialize Autoconf
AC_INIT([lpscoins Core], [CLIENT_VERSION], [www.lpscoins.org], [lpscoins])
AC_CONFIG_SRCDIR([src/main.cpp])
AC_CONFIG_HEADERS([src/config/lpscoins-config.h])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux/m4])

# Canonicalize host
AC_CANONICAL_HOST

# Configure header guards
AH_TOP([#ifndef LPSCOINS_CONFIG_H])
AH_TOP([#define LPSCOINS_CONFIG_H])
AH_BOTTOM([#endif //LPSCOINS_CONFIG_H])

# Disable faketime during configure
AS_UNSET([FAKETIME])

# Initialize Automake
AM_INIT_AUTOMAKE([1.13 foreign subdir-objects])
AM_MAINTAINER_MODE([enable])

# Silence compilation unless V=1
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# Compiler setup
AC_PROG_CXX
AX_CXX_COMPILE_STDCXX([11], [noext], [mandatory])

# Check if CXXFLAGS were overridden
AS_IF([test "x${CXXFLAGS+set}" = "xset"], [CXXFLAGS_overridden=yes], [CXXFLAGS_overridden=no])

# Libtool setup
LT_INIT([pic-only])

# Default compiler flags
AS_IF([test "x$CXXFLAGS_overridden" = "xno"],
      [CXXFLAGS="$CXXFLAGS -Wall -Wextra -Wformat -Wformat-security -Wno-unused-parameter"])
CPPFLAGS="$CPPFLAGS -DBOOST_SPIRIT_THREADSAFE -DHAVE_BUILD_INFO -D__STDC_FORMAT_MACROS"

# Tool detection
AC_PATH_TOOLS([AR], [ar])
AC_PATH_TOOLS([RANLIB], [ranlib])
AC_PATH_TOOLS([STRIP], [strip])
AC_PATH_TOOLS([GCOV], [gcov])
AC_PATH_PROGS([LCOV], [lcov])
AC_PATH_PROGS([JAVA], [java])
AC_PATH_PROGS([PYTHON], [python3 python2.7 python2 python])
AC_PATH_PROGS([GENHTML], [genhtml])
AC_PATH_PROGS([GIT], [git])
AC_PATH_PROGS([CCACHE], [ccache])
AC_PATH_PROGS([XGETTEXT], [xgettext])
AC_PATH_PROGS([HEXDUMP], [hexdump])
AC_PATH_TOOLS([READELF], [readelf])
AC_PATH_TOOLS([CPPFILT], [c++filt])
AC_PATH_TOOLS([OBJCOPY], [objcopy])

# Include pkg-config m4
m4_include([pkg.m4])
PKG_PROG_PKG_CONFIG

# Configuration options
AC_ARG_ENABLE([wallet], [AS_HELP_STRING([--enable-wallet], [enable wallet (default is yes)])], [enable_wallet=$enableval], [enable_wallet=yes])
AC_ARG_WITH([miniupnpc], [AS_HELP_STRING([--with-miniupnpc], [enable UPNP (default is auto)])], [use_upnp=$withval], [use_upnp=auto])
AC_ARG_ENABLE([upnp-default], [AS_HELP_STRING([--enable-upnp-default], [enable UPNP at startup (default is no)])], [use_upnp_default=$enableval], [use_upnp_default=no])
AC_ARG_ENABLE([tests], [AS_HELP_STRING([--enable-tests], [compile tests (default is yes)])], [use_tests=$enableval], [use_tests=yes])
AC_ARG_WITH([comparison-tool], [AS_HELP_STRING([--with-comparison-tool], [path to java comparison tool])], [use_comparison_tool=$withval], [use_comparison_tool=no])
AC_ARG_ENABLE([comparison-tool-reorg-tests], [AS_HELP_STRING([--enable-comparison-tool-reorg-tests], [enable reorg tests (default no)])], [use_comparison_tool_reorg_tests=$enableval], [use_comparison_tool_reorg_tests=no])
AC_ARG_WITH([qrencode], [AS_HELP_STRING([--with-qrencode], [enable QR code support (default is auto)])], [use_qr=$withval], [use_qr=auto])
AC_ARG_ENABLE([hardening], [AS_HELP_STRING([--enable-hardening], [harden executables (default is yes)])], [use_hardening=$enableval], [use_hardening=yes])
AC_ARG_enable([reduce-exports], [AS_HELP_STRING([--enable-reduce-exports], [reduce exported symbols (default is auto)])], [use_reduce_exports=$enableval], [use_reduce_exports=auto])
AC_ARG_ENABLE([ccache], [AS_HELP_STRING([--enable-ccache], [use ccache (default is auto)])], [use_ccache=$enableval], [use_ccache=auto])
AC_ARG_ENABLE([lcov], [AS_HELP_STRING([--enable-lcov], [enable lcov testing (default is no)])], [use_lcov=$enableval], [use_lcov=no])
AC_ARG_ENABLE([glibc-back-compat], [AS_HELP_STRING([--enable-glibc-back-compat], [enable glibc/libstdc++ compatibility])], [use_glibc_compat=$enableval], [use_glibc_compat=no])
AC_ARG_ENABLE([zmq], [AS_HELP_STRING([--disable-zmq], [disable ZMQ notifications (default is yes)])], [use_zmq=$enableval], [use_zmq=yes])
AC_ARG_WITH([protoc-bindir], [AS_HELP_STRING([--with-protoc-bindir=BIN_DIR], [specify protoc bin path])], [protoc_bin_path=$withval], [protoc_bin_path=])
AC_ARG_ENABLE([debug], [AS_HELP_STRING([--enable-debug], [enable debug flags (default is no)])], [enable_debug=$enableval], [enable_debug=no])
AC_ARG_WITH([utils], [AS_HELP_STRING([--with-utils], [build lpscoins-cli and lpscoins-tx (default is yes)])], [build_utils=$withval], [build_utils=yes])
AC_ARG_WITH([libs], [AS_HELP_STRING([--with-libs], [build libraries (default is yes)])], [build_libs=$withval], [build_libs=yes])
AC_ARG_WITH([daemon], [AS_HELP_STRING([--with-daemon], [build lpscoinsd (default is yes)])], [build_daemon=$withval], [build_daemon=yes])
AC_ARG_ENABLE([mixing], [AS_HELP_STRING([--enable-mixing], [enable coin mixing for privacy (default is yes)])], [enable_mixing=$enableval], [enable_mixing=yes])
AC_ARG_ENABLE([fastsend], [AS_HELP_STRING([--enable-fastsync], [enable FastSend for zero-conf transactions (default is yes)])], [enable_fastsync=$enableval], [enable_fastsync=yes])

# Debug mode
AS_IF([test "x$enable_debug" = "xyes"],
      [CFLAGS="-g3 -O0 -DDEBUG"
       CXXFLAGS="-g3 -O0 -DDEBUG -fsanitize=address,undefined"
       LDFLAGS="$LDFLAGS -fsanitize=address,undefined"])

# Platform-specific settings
use_pkgconfig=yes
case $host in
  *mingw*)
    use_pkgconfig=no
    TARGET_OS=windows
    AC_CHECK_LIBS([mingwthrd kernel32 user32 gdi32 comdlg32 winspool winmm shell32 comctl32 ole32 oleaut32 uuid rpcrt4 advapi32 ws2_32 mswsock shlwapi iphlpapi crypt32], [main], [], [AC_MSG_ERROR([Required Windows library missing])])
    AX_CHECK_LINK_FLAG([[-static-libgcc -static-libstdc++]], [LIBTOOL_APP_LDFLAGS="$LIBTOOL_APP_LDFLAGS -static-libgcc -static-libstdc++"])
    AC_PATH_PROGS([MAKENSIS], [makensis], [none])
    AS_IF([test "x$MAKENSIS" = "xnone"], [AC_MSG_WARN([makensis not found; cannot create installer])])
    AC_PATH_TOOLS([WINDRES], [windres], [], [AC_MSG_ERROR([windres not found])])
    CPPFLAGS="$CPPFLAGS -D_MT -DWIN32 -D_WINDOWS -DBOOST_THREAD_USE_LIB"
    LEVELDB_TARGET_FLAGS="TARGET_OS=OS_WINDOWS_CROSSCOMPILE"
    AS_IF([test "
