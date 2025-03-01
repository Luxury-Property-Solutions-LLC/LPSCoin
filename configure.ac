# Require Autoconf 2.69 or newer for improved macro support and AS_VAR_IF
AC_PREREQ([2.69])

# Define version and metadata as m4 constants
m4_define([CLIENT_VERSION_MAJOR], [4])
m4_define([CLIENT_VERSION_MINOR], [1])
m4_define([CLIENT_VERSION_REVISION], [0])
m4_define([CLIENT_VERSION_BUILD], [0])
m4_define([CLIENT_VERSION_IS_RELEASE], [true])
m4_define([COPYRIGHT_YEAR], [2025])  # Updated to current year
m4_define([CLIENT_VERSION], [CLIENT_VERSION_MAJOR.CLIENT_VERSION_MINOR.CLIENT_VERSION_REVISION])

# Initialize Autoconf
AC_INIT([LPSCoin Core], [CLIENT_VERSION], [https://lpscoin.org], [lpscoin])
AC_CONFIG_SRCDIR([src/main.cpp])
AC_CONFIG_HEADERS([src/config/lpscoins-config.h])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux/m4])

# Canonicalize host for platform-specific checks
AC_CANONICAL_HOST

# Configure header guards
AH_TOP([#ifndef LPSCOINS_CONFIG_H])
AH_TOP([#define LPSCOINS_CONFIG_H])
AH_BOTTOM([#endif //LPSCOINS_CONFIG_H])

# Disable faketime during configure (used only for make)
AS_UNSET([FAKETIME])

# Initialize Automake with modern options
AM_INIT_AUTOMAKE([1.13 foreign subdir-objects])
AM_MAINTAINER_MODE([enable])

# Silence compilation unless V=1
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# Compiler checks
# C++11 required
AC_PROG_CXX
AX_CXX_COMPILE_STDCXX([11], [noext], [mandatory])

# Check if CXXFLAGS were overridden by the user
AS_IF([test "x${CXXFLAGS+set}" = "xset"], [CXXFLAGS_overridden=yes], [CXXFLAGS_overridden=no])

# Libtool setup for portable library building
LT_INIT([pic-only])

# Default compiler flags (unless overridden)
AS_IF([test "x$CXXFLAGS_overridden" = "xno"],
      [AX_CHECK_COMPILE_FLAG([-Wall], [CXXFLAGS="$CXXFLAGS -Wall"])
       AX_CHECK_COMPILE_FLAG([-Wextra], [CXXFLAGS="$CXXFLAGS -Wextra"])
       AX_CHECK_COMPILE_FLAG([-Wformat], [CXXFLAGS="$CXXFLAGS -Wformat"])
       AX_CHECK_COMPILE_FLAG([-Wformat-security], [CXXFLAGS="$CXXFLAGS -Wformat-security"])
       AX_CHECK_COMPILE_FLAG([-Wno-unused-parameter], [CXXFLAGS="$CXXFLAGS -Wno-unused-parameter"])])
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

# Include pkg-config m4 if not found system-wide
m4_ifndef([PKG_PROG_PKG_CONFIG], [m4_fatal([pkg.m4 not found in AC_CONFIG_MACRO_DIR])])
PKG_PROG_PKG_CONFIG

# Configuration options
AC_ARG_ENABLE([wallet],
  [AS_HELP_STRING([--enable-wallet], [enable wallet (default is yes)])],
  [enable_wallet=$enableval], [enable_wallet=yes])
AC_ARG_WITH([miniupnpc],
  [AS_HELP_STRING([--with-miniupnpc], [enable UPNP (default is auto)])],
  [use_upnp=$withval], [use_upnp=auto])
AC_ARG_ENABLE([upnp-default],
  [AS_HELP_STRING([--enable-upnp-default], [enable UPNP at startup (default is no)])],
  [use_upnp_default=$enableval], [use_upnp_default=no])
AC_ARG_ENABLE([tests],
  [AS_HELP_STRING([--enable-tests], [compile tests (default is yes)])],
  [use_tests=$enableval], [use_tests=yes])
AC_ARG_WITH([comparison-tool],
  [AS_HELP_STRING([--with-comparison-tool], [path to java comparison tool (requires --enable-tests)])],
  [use_comparison_tool=$withval], [use_comparison_tool=no])
AC_ARG_ENABLE([comparison-tool-reorg-tests],
  [AS_HELP_STRING([--enable-comparison-tool-reorg-tests], [enable reorg tests in comparison tool (default no)])],
  [use_comparison_tool_reorg_tests=$enableval], [use_comparison_tool_reorg_tests=no])
AC_ARG_WITH([qrencode],
  [AS_HELP_STRING([--with-qrencode], [enable QR code support (default is auto)])],
  [use_qr=$withval], [use_qr=auto])
AC_ARG_ENABLE([hardening],
  [AS_HELP_STRING([--enable-hardening], [harden executables (default is yes)])],
  [use_hardening=$enableval], [use_hardening=yes])
AC_ARG_ENABLE([reduce-exports],
  [AS_HELP_STRING([--enable-reduce-exports], [reduce exported symbols (default is auto)])],
  [use_reduce_exports=$enableval], [use_reduce_exports=auto])
AC_ARG_ENABLE([ccache],
  [AS_HELP_STRING([--enable-ccache], [use ccache (default is auto)])],
  [use_ccache=$enableval], [use_ccache=auto])
AC_ARG_ENABLE([lcov],
  [AS_HELP_STRING([--enable-lcov], [enable lcov testing (default is no)])],
  [use_lcov=$enableval], [use_lcov=no])
AC_ARG_ENABLE([glibc-back-compat],
  [AS_HELP_STRING([--enable-glibc-back-compat], [enable glibc/libstdc++ backwards compatibility])],
  [use_glibc_compat=$enableval], [use_glibc_compat=no])
AC_ARG_ENABLE([zmq],
  [AS_HELP_STRING([--disable-zmq], [disable ZMQ notifications (default is yes)])],
  [use_zmq=$enableval], [use_zmq=yes])
AC_ARG_WITH([protoc-bindir],
  [AS_HELP_STRING([--with-protoc-bindir=BIN_DIR], [specify protoc bin path])],
  [protoc_bin_path=$withval], [protoc_bin_path=])
AC_ARG_ENABLE([debug],
  [AS_HELP_STRING([--enable-debug], [enable debug flags (default is no)])],
  [enable_debug=$enableval], [enable_debug=no])
AC_ARG_WITH([utils],
  [AS_HELP_STRING([--with-utils], [build lpscoins-cli and lpscoins-tx (default is yes)])],
  [build_utils=$withval], [build_utils=yes])
AC_ARG_WITH([libs],
  [AS_HELP_STRING([--with-libs], [build libraries (default is yes)])],
  [build_libs=$withval], [build_libs=yes])
AC_ARG_WITH([daemon],
  [AS_HELP_STRING([--with-daemon], [build lpscoinsd (default is yes)])],
  [build_daemon=$withval], [build_daemon=yes])
AC_ARG_ENABLE([mixing],
  [AS_HELP_STRING([--enable-mixing], [enable Coin Mixing for privacy (default is yes)])],
  [enable_mixing=$enableval], [enable_mixing=yes])
AC_ARG_ENABLE([fastsend],
  [AS_HELP_STRING([--enable-fastsend], [enable FastSend for zero-conf transactions (default is yes)])],
  [enable_fastsync=$enableval], [enable_fastsync=yes])
AC_ARG_ENABLE([masternodes],
  [AS_HELP_STRING([--enable-masternodes], [enable masternode support (default is yes)])],
  [enable_masternodes=$enableval], [enable_masternodes=yes])

# Debug mode settings
AS_IF([test "x$enable_debug" = "xyes"],
      [AX_CHECK_COMPILE_FLAG([-g3], [CFLAGS="$CFLAGS -g3" CXXFLAGS="$CXXFLAGS -g3"])
       AX_CHECK_COMPILE_FLAG([-O0], [CFLAGS="$CFLAGS -O0" CXXFLAGS="$CXXFLAGS -O0"])
       AC_DEFINE([DEBUG], [1], [Define if debugging is enabled])
       AS_IF([test "x$TARGET_OS" != "xwindows"],
             [AX_CHECK_COMPILE_FLAG([-fsanitize=address], [CXXFLAGS="$CXXFLAGS -fsanitize=address"])
              AX_CHECK_COMPILE_FLAG([-fsanitize=undefined], [CXXFLAGS="$CXXFLAGS -fsanitize=undefined"])
              AX_CHECK_LINK_FLAG([-fsanitize=address], [LDFLAGS="$LDFLAGS -fsanitize=address"])
              AX_CHECK_LINK_FLAG([-fsanitize=undefined], [LDFLAGS="$LDFLAGS -fsanitize=undefined"])])])

# Platform-specific settings
use_pkgconfig=yes
case $host in
  *mingw*)
    use_pkgconfig=no
    TARGET_OS=windows
    AC_CHECK_LIBS([mingwthrd kernel32 user32 gdi32 comdlg32 winspool winmm shell32 comctl32 ole32 oleaut32 uuid rpcrt4 advapi32 ws2_32 mswsock shlwapi iphlpapi crypt32], [main], [],
                  [AC_MSG_ERROR([Required Windows library missing])])
    AX_CHECK_LINK_FLAG([[-static-libgcc]], [LIBTOOL_APP_LDFLAGS="$LIBTOOL_APP_LDFLAGS -static-libgcc"])
    AX_CHECK_LINK_FLAG([[-static-libstdc++]], [LIBTOOL_APP_LDFLAGS="$LIBTOOL_APP_LDFLAGS -static-libstdc++"])
    AC_PATH_PROGS([MAKENSIS], [makensis], [none])
    AS_IF([test "x$MAKENSIS" = "xnone"], [AC_MSG_WARN([makensis not found; cannot create installer])])
    AC_PATH_TOOLS([WINDRES], [windres], [], [AC_MSG_ERROR([windres not found])])
    CPPFLAGS="$CPPFLAGS -D_MT -DWIN32 -D_WINDOWS -DBOOST_THREAD_USE_LIB"
    LEVELDB_TARGET_FLAGS="TARGET_OS=OS_WINDOWS_CROSSCOMPILE"
    AS_IF([test "x$CXXFLAGS_overridden" = "xno"], [AX_CHECK_COMPILE_FLAG([-w], [CXXFLAGS="$CXXFLAGS -w"])])
    case $host in
      i?86-*) WINDOWS_BITS=32 ;;
      x86_64-*) WINDOWS_BITS=64 ;;
      *) AC_MSG_ERROR([Unknown Windows architecture for installer]) ;;
    esac
    AC_SUBST([WINDOWS_BITS])
    archive_cmds_CXX="\$CC -shared \$libobjs \$deplibs \$compiler_flags -static -o \$output_objdir/\$soname \${wl}--enable-auto-image-base -Xlinker --out-implib -Xlinker \$lib"
    postdeps_CXX=
    ;;
  *darwin*)
    TARGET_OS=darwin
    LEVELDB_TARGET_FLAGS="TARGET_OS=Darwin"
    AS_IF([test "x$cross_compiling" != "xyes"],
          [BUILD_OS=darwin
           AC_CHECK_PROGS([PORT], [port])
           AS_IF([test "x$PORT" = "xport"],
                 [CPPFLAGS="$CPPFLAGS -isystem /opt/local/include"
                  LIBS="$LIBS -L/opt/local/lib"
                  AS_IF([test -d /opt/local/include/db48],
                        [CPPFLAGS="$CPPFLAGS -I/opt/local/include/db48"
                         LIBS="$LIBS -L/opt/local/lib/db48"])])
           AC_CHECK_PROGS([BREW], [brew])
           AS_IF([test "x$BREW" = "xbrew"],
                 [openssl_prefix=`$BREW --prefix openssl@3 2>/dev/null || $BREW --prefix openssl 2>/dev/null`
                  bdb_prefix=`$BREW --prefix berkeley-db@4 2>/dev/null || $BREW --prefix berkeley-db 2>/dev/null`
                  qt5_prefix=`$BREW --prefix qt@5 2>/dev/null || $BREW --prefix qt 2>/dev/null`
                  AS_IF([test "x$openssl_prefix" != "x"], [PKG_CONFIG_PATH="$openssl_prefix/lib/pkgconfig:$PKG_CONFIG_PATH"])
                  AS_IF([test "x$bdb_prefix" != "x"], [CPPFLAGS="$CPPFLAGS -I$bdb_prefix/include" LIBS="$LIBS -L$bdb_prefix/lib"])
                  AS_IF([test "x$qt5_prefix" != "x"], [PKG_CONFIG_PATH="$qt5_prefix/lib/pkgconfig:$PKG_CONFIG_PATH"])
                  export PKG_CONFIG_PATH])],
          [case $build_os in
             *darwin*) BUILD_OS=darwin ;;
             *) AC_PATH_TOOLS([INSTALLNAMETOOL], [install_name_tool], [install_name_tool])
                AC_PATH_TOOLS([OTOOL], [otool], [otool])
                AC_PATH_PROGS([GENISOIMAGE], [genisoimage mkisofs], [genisoimage])
                old_striplib= ;;
           esac])
    AX_CHECK_LINK_FLAG([[-Wl,-headerpad_max_install_names]], [LDFLAGS="$LDFLAGS -Wl,-headerpad_max_install_names"])
    CPPFLAGS="$CPPFLAGS -DMAC_OSX"
    ;;
  *linux*)
    TARGET_OS=linux
    ;;
esac

# Feature checks
AX_PTHREAD
AC_SYS_LARGEFILE
AC_FUNC_STRERROR_R
AX_CHECK_LINK_FLAG([[-Wl,--large-address-aware]], [LDFLAGS="$LDFLAGS -Wl,--large-address-aware"])
AX_GCC_FUNC_ATTRIBUTE([visibility])
AX_GCC_FUNC_ATTRIBUTE([dllexport])
AX_GCC_FUNC_ATTRIBUTE([dllimport])

AS_IF([test "x$use_glibc_compat" != "xno"],
      [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#define _FORTIFY_SOURCE 2
                                            #include <sys/select.h>
                                            extern "C" long unsigned int __fdelt_warn(long unsigned int);]], [[]])],
                         [AC_DEFINE([FDELT_TYPE], [long unsigned int], [Parameter type for __fdelt_chk])],
                         [AC_DEFINE([FDELT_TYPE], [long int], [Parameter type for __fdelt_chk])])])

AS_IF([test "x$use_hardening" != "xno"],
      [AX_CHECK_COMPILE_FLAG([-Wstack-protector], [HARDENED_CXXFLAGS="$HARDENED_CXXFLAGS -Wstack-protector"])
       AX_CHECK_COMPILE_FLAG([-fstack-protect-strong], [HARDENED_CXXFLAGS="$HARDENED_CXXFLAGS -fstack-protect-strong"], [],
                             [AX_CHECK_COMPILE_FLAG([-fstack-protector-all], [HARDENED_CXXFLAGS="$HARDENED_CXXFLAGS -fstack-protector-all"])])
       AX_CHECK_PREPROC_FLAG([-D_FORTIFY_SOURCE=2], [HARDENED_CPPFLAGS="$HARDENED_CPPFLAGS -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2"])
       AX_CHECK_LINK_FLAG([[-Wl,--dynamicbase]], [HARDENED_LDFLAGS="$HARDENED_LDFLAGS -Wl,--dynamicbase"])
       AX_CHECK_LINK_FLAG([[-Wl,--nxcompat]], [HARDENED_LDFLAGS="$HARDENED_LDFLAGS -Wl,--nxcompat"])
       AX_CHECK_LINK_FLAG([[-Wl,-z,relro]], [HARDENED_LDFLAGS="$HARDENED_LDFLAGS -Wl,-z,relro"])
       AX_CHECK_LINK_FLAG([[-Wl,-z,now]], [HARDENED_LDFLAGS="$HARDENED_LDFLAGS -Wl,-z,now"])
       AS_IF([test "x$TARGET_OS" != "xwindows"],
             [AX_CHECK_COMPILE_FLAG([-fPIC], [HARDENED_CXXFLAGS="$HARDENED_CXXFLAGS -fPIC"])
              AX_CHECK_LINK_FLAG([[-pic]], [HARDENED_LDFLAGS="$HARDENED_LDFLAGS -pic"])])
       AS_IF([test "x$host" = "x*mingw*"], [AC_CHECK_LIB([ssp], [main], [], [AC_MSG_ERROR([libssp missing])])])
       CXXFLAGS="$CXXFLAGS $HARDENED_CXXFLAGS"
       CPPFLAGS="$CPPFLAGS $HARDENED_CPPFLAGS"
       LDFLAGS="$LDFLAGS $HARDENED_LDFLAGS"])

AS_IF([test "x$TARGET_OS" = "xdarwin"],
      [AX_CHECK_LINK_FLAG([[-Wl,-dead_strip]], [LDFLAGS="$LDFLAGS -Wl,-dead_strip"])])

AC_CHECK_HEADERS([endian.h stdio.h stdlib.h unistd.h strings.h sys/types.h sys/stat.h sys/select.h sys/prctl.h])
AC_SEARCH_LIBS([getaddrinfo_a], [anl], [AC_DEFINE([HAVE_GETADDRINFO_A], [1], [Define if getaddrinfo_a is available])])
AC_SEARCH_LIBS([inet_pton], [nsl resolv], [AC_DEFINE([HAVE_INET_PTON], [1], [Define if inet_pton is available])])
AC_CHECK_DECLS([strnlen])
AC_CHECK_DECLS([le32toh le64toh htole32 htole64 be32toh be64toh htobe32 htobe64], [], [], [[#include <endian.h>]])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <sys/socket.h>]], [[int f = MSG_NOSIGNAL;]])],
                  [AC_DEFINE([HAVE_MSG_NOSIGNAL], [1], [Define if MSG_NOSIGNAL is available])], [])
AC_SEARCH_LIBS([clock_gettime], [rt])

# Boost configuration (required unless all components disabled)
AS_IF([test "x$build_utils$build_daemon$bitcoin_enable_qt$use_tests" = "xnononono"],
      [use_boost=no], [use_boost=yes])

AS_IF([test "x$use_boost" = "xyes"],
      [AX_BOOST_BASE([1.64.0], [AC_MSG_NOTICE([Boost 1.64.0+ detected])], [AC_MSG_ERROR([Boost 1.64.0 or higher required])])
       AX_BOOST_SYSTEM
       AX_BOOST_FILESYSTEM
       AX_BOOST_PROGRAM_OPTIONS
       AX_BOOST_THREAD
       AX_BOOST_CHRONO
       BOOST_LIBS="$BOOST_LDFLAGS $BOOST_SYSTEM_LIB $BOOST_FILESYSTEM_LIB $BOOST_PROGRAM_OPTIONS_LIB $BOOST_THREAD_LIB $BOOST_CHRONO_LIB"
       AS_IF([test "x$ax_cv_boost_chrono" = "xyes"],
             [AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <boost/thread/thread.hpp>
                                                #include <boost/version.hpp>]],
                                              [[#if BOOST_VERSION >= 105000 && (!defined(BOOST_HAS_NANOSLEEP) || BOOST_VERSION >= 105200)
                                                boost::this_thread::sleep_for(boost::chrono::milliseconds(0));
                                                #else
                                                choke me
                                                #endif]])],
                             [AC_DEFINE([HAVE_WORKING_BOOST_SLEEP_FOR], [1], [Define if boost sleep_for works])],
                             [AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <boost/version.hpp>
                                                                #include <boost/thread.hpp>
                                                                #include <boost/date_time/posix_time/posix_time_types.hpp>]],
                                                              [[#if BOOST_VERSION <= 105600
                                                                boost::this_thread::sleep(boost::posix_time::milliseconds(0));
                                                                #else
                                                                choke me
                                                                #endif]])],
                                             [AC_DEFINE([HAVE_WORKING_BOOST_SLEEP], [1], [Define if boost sleep works])],
                                             [AC_MSG_ERROR([No working boost sleep implementation found])])])])])

# LPSCoin-specific features
AS_IF([test "x$enable_mixing" = "xyes"], [AC_DEFINE([ENABLE_MIXING], [1], [Define to enable Coin Mixing])])
AS_IF([test "x$enable_fastsync" = "xyes"], [AC_DEFINE([ENABLE_FASTSEND], [1], [Define to enable FastSend])])
AS_IF([test "x$enable_masternodes" = "xyes"], [AC_DEFINE([ENABLE_MASTERNODES], [1], [Define to enable masternode support])])

# Dependency checks
AS_IF([test "x$enable_wallet" != "xno"], [BITCOIN_FIND_BDB48])
AS_IF([test "x$use_upnp" != "xno"],
      [AC_CHECK_HEADERS([miniupnpc/miniwget.h miniupnpc/miniupnpc.h miniupnpc/upnpcommands.h miniupnpc/upnperrors.h],
                        [AC_CHECK_LIB([miniupnpc], [main], [MINIUPNPC_LIBS=-lminiupnpc], [have_miniupnpc=no])],
                        [have_miniupnpc=no])])

BITCOIN_QT_INIT
BITCOIN_QT_CONFIGURE([$use_pkgconfig], [qt5])

AS_IF([test "x$bitcoin_enable_qt" = "xyes" && test "x$bitcoin_qt_got_major_vers" = "x5"],
      [AC_DEFINE([HAVE_QT5], [1], [Define to enable trading dialog])])

AS_IF([test "x$use_pkgconfig" = "xyes"],
      [PKG_CHECK_MODULES([SSL], [libssl], [], [AC_MSG_ERROR([OpenSSL not found])])
       PKG_CHECK_MODULES([CRYPTO], [libcrypto], [], [AC_MSG_ERROR([libcrypto not found])])
       BITCOIN_QT_CHECK([PKG_CHECK_MODULES([PROTOBUF], [protobuf], [have_protobuf=yes], [BITCOIN_QT_FAIL([libprotobuf not found])])])
       AS_IF([test "x$use_qr" != "xno"], [BITCOIN_QT_CHECK([PKG_CHECK_MODULES([QR], [libqrencode], [have_qrencode=yes], [have_qrencode=no])])])
       AS_IF([test "x$use_zmq" = "xyes"],
             [PKG_CHECK_MODULES([ZMQ], [libzmq >= 4], [AC_DEFINE([ENABLE_ZMQ], [1], [Define to enable ZMQ])],
                                [AC_DEFINE([ENABLE_ZMQ], [0], [Define to enable ZMQ])
                                 AC_MSG_WARN([libzmq >= 4 not found, disabling ZMQ])
                                 use_zmq=no])],
             [AC_DEFINE([ENABLE_ZMQ], [0], [Define to enable ZMQ])])],
      [AC_CHECK_HEADER([openssl/crypto.h], [], [AC_MSG_ERROR([libcrypto headers missing])])
       AC_CHECK_LIB([crypto], [main], [CRYPTO_LIBS=-lcrypto], [AC_MSG_ERROR([libcrypto missing])])
       AC_CHECK_HEADER([openssl/ssl.h], [], [AC_MSG_ERROR([libssl headers missing])])
       AC_CHECK_LIB([ssl], [main], [SSL_LIBS=-lssl], [AC_MSG_ERROR([libssl missing])])
       AS_IF([test "x$use_zmq" = "xyes"],
             [AC_CHECK_HEADER([zmq.h], [AC_DEFINE([ENABLE_ZMQ], [1], [Define to enable ZMQ])],
                              [AC_MSG_WARN([zmq.h not found, disabling ZMQ])
                               use_zmq=no
                               AC_DEFINE([ENABLE_ZMQ], [0], [Define to enable ZMQ])])
              AC_CHECK_LIB([zmq], [zmq_ctx_shutdown], [ZMQ_LIBS=-lzmq], [AC_MSG_WARN([libzmq >= 4 not found, disabling ZMQ])
                                                                         use_zmq=no
                                                                         AC_DEFINE([ENABLE_ZMQ], [0], [Define to enable ZMQ])])],
             [AC_DEFINE([ENABLE_ZMQ], [0], [Define to enable ZMQ])])
       BITCOIN_QT_CHECK([AC_CHECK_LIB([protobuf], [main], [PROTOBUF_LIBS=-lprotobuf], [BITCOIN_QT_FAIL([libprotobuf not found])])])
       AS_IF([test "x$use_qr" != "xno"],
             [BITCOIN_QT_CHECK([AC_CHECK_LIB([qrencode], [main], [QR_LIBS=-lqrencode], [have_qrencode=no])])
              BITCOIN_QT_CHECK([AC_CHECK_HEADER([qrencode.h], [], [have_qrencode=no])])])])

AC_CHECK_LIB([crypto], [RAND_egd], [],
             [AC_ARG_WITH([libressl], [AS_HELP_STRING([--with-libressl], [Build with LibreSSL (default no; DANGEROUS)])],
                          [AC_MSG_WARN([LibreSSL detected: NOT supported, may break consensus])],
                          [AC_MSG_ERROR([LibreSSL detected: NOT supported, may break consensus])])])

AC_CHECK_HEADER([openssl/ec.h], [], [AC_MSG_ERROR([OpenSSL ec header missing])], [$SSL_CFLAGS $CRYPTO_CFLAGS])

BITCOIN_QT_PATH_PROGS([PROTOC], [protoc], [$protoc_bin_path])

# Build options
AM_CONDITIONAL([BUILD_DAEMON], [test "x$build_daemon" = "xyes"])
AM_CONDITIONAL([BUILD_UTILS], [test "x$build_utils" = "xyes"])
AM_CONDITIONAL([BUILD_LIBS], [test "x$build_libs" = "xyes"])
AS_IF([test "x$build_libs" = "xyes"], [AC_DEFINE([HAVE_CONSENSUS_LIB], [1], [Define if consensus lib is built])])

AS_IF([test "x$enable_wallet" != "xno"], [AC_DEFINE([ENABLE_WALLET], [1], [Define to enable wallet])])
AS_IF([test "x$have_miniupnpc" != "xno" && test "x$use_upnp" != "xno"],
      [use_upnp=yes
       AS_IF([test "x$use_upnp_default" != "xno"], [upnp_setting=1], [upnp_setting=0])
       AC_DEFINE_UNQUOTED([USE_UPNP], [$upnp_setting], [Define to set default UPNP state])
       AS_IF([test "x$TARGET_OS" = "xwindows"], [MINIUPNPC_CPPFLAGS="-DSTATICLIB -DMINIUPNP_STATICLIB"])])

AS_IF([test "x$bitcoin_enable_qt" != "xno"],
      [BUILD_QT=qt
       AS_IF([test "x$bitcoin_enable_qt_dbus" != "xno"], [AC_DEFINE([USE_DBUS], [1], [Define to enable D-Bus])])
       AS_IF([test "x$have_qrencode" != "xno" && test "x$use_qr" != "xno"],
             [AC_DEFINE([USE_QRCODE], [1], [Define to enable QR support])
              use_qr=yes])
       AS_IF([test "x$use_tests$bitcoin_enable_qt_test" = "xyesyes"], [BUILD_TEST_QT=test])])

AM_CONDITIONAL([ENABLE_TESTS], [test "x$use_tests" = "xyes"])
AS_IF([test "x$use_tests" = "xyes" && test "x$HEXDUMP" = "x"], [AC_MSG_ERROR([hexdump required for tests])])

AS_IF([test "x$use_reduce_exports" != "xno"],
      [AX_CHECK_COMPILE_FLAG([-fvisibility=hidden], [RE_CXXFLAGS="-fvisibility=hidden"],
                            [AS_IF([test "x$use_reduce_exports" = "xyes"], [AC_MSG_ERROR([Cannot set visibility; use --disable-reduce-exports])])
                             use_reduce_exports=no])
       CXXFLAGS="$CXXFLAGS $RE_CXXFLAGS"
       AX_CHECK_LINK_FLAG([[-Wl,--exclude-libs,ALL]], [RELDFLAGS="-Wl,--exclude-libs,ALL"])])

AM_CONDITIONAL([ENABLE_ZMQ], [test "x$use_zmq" = "xyes"])
AM_CONDITIONAL([TARGET_DARWIN], [test "x$TARGET_OS" = "xdarwin"])
AM_CONDITIONAL([BUILD_DARWIN], [test "x$BUILD_OS" = "xdarwin"])
AM_CONDITIONAL([TARGET_WINDOWS], [test "x$TARGET_OS" = "xwindows"])
AM_CONDITIONAL([ENABLE_WALLET], [test "x$enable_wallet" = "xyes"])
AM_CONDITIONAL([ENABLE_QT], [test "x$bitcoin_enable_qt" = "xyes"])
AM_CONDITIONAL([HAVE_QT5], [test "x$bitcoin_qt_got_major_vers" = "x5"])
AM_CONDITIONAL([ENABLE_QT_TESTS], [test "x$use_tests$bitcoin_enable_qt_test" = "xyesyes"])
AM_CONDITIONAL([USE_QRCODE], [test "x$use_qr" = "xyes"])
AM_CONDITIONAL([USE_LCOV], [test "x$use_lcov" = "xyes"])
AM_CONDITIONAL([USE_COMPARISON_TOOL], [test "x$use_comparison_tool" != "xno"])
AM_CONDITIONAL([USE_COMPARISON_TOOL_REORG_TESTS], [test "x$use_comparison_tool_reorg_tests" != "xno"])
AM_CONDITIONAL([GLIBC_BACK_COMPAT], [test "x$use_glibc_compat" = "xyes"])

# Define version macros
AC_DEFINE_UNQUOTED([CLIENT_VERSION_MAJOR], [CLIENT_VERSION_MAJOR], [Major version])
AC_DEFINE_UNQUOTED([CLIENT_VERSION_MINOR], [CLIENT_VERSION_MINOR], [Minor version])
AC_DEFINE_UNQUOTED([CLIENT_VERSION_REVISION], [CLIENT_VERSION_REVISION], [Build revision])
AC_DEFINE_UNQUOTED([CLIENT_VERSION_BUILD], [CLIENT_VERSION_BUILD], [Version build])
AC_DEFINE_UNQUOTED([CLIENT_VERSION_IS_RELEASE], [CLIENT_VERSION_IS_RELEASE], [Version is release])
AC_DEFINE_UNQUOTED([COPYRIGHT_YEAR], [COPYRIGHT_YEAR], [Copyright year])

# Substitute variables
AC_SUBST([RELDFLAGS])
AC_SUBST([LIBTOOL_APP_LDFLAGS])
AC_SUBST([USE_UPNP])
AC_SUBST([USE_QRCODE])
AC_SUBST([BOOST_LIBS])
AC_SUBST([LEVELDB_TARGET_FLAGS])
AC_SUBST([BUILD_QT])
AC_SUBST([BUILD_TEST_QT])
AC_SUBST([MINIUPNPC_CPPFLAGS])
AC_SUBST([MINIUPNPC_LIBS])

# Generate files
AC_CONFIG_FILES([Makefile src/Makefile share/setup.nsi share/qt/Info.plist src/test/buildenv.py
                 qa/pull-tester/run-bitcoind-for-test.sh:qa/pull-tester/run-bitcoind-for-test.sh
                 qa/pull-tester/tests-config.sh:qa/pull-tester/tests-config.sh
                 contrib/devtools/split-debug.sh:contrib/devtools/split-debug.sh],
                [chmod +x qa/pull-tester/run-bitcoind-for-test.sh qa/pull-tester/tests-config.sh contrib/devtools/split-debug.sh])

AC_CONFIG_SUBDIRS([src/secp256k1])
ac_configure_args="${ac_configure_args} --disable-shared --with-pic"

AC_OUTPUT

# Fix libtool for Linux rpath issues
case $host in
  *-*-linux-gnu)
    AC_MSG_RESULT([Fixing libtool for -rpath problems])
    sed < libtool > libtool-2 's/^hardcode_libdir_flag_spec.*$/hardcode_libdir_flag_spec=" -D__LIBTOOL_IS_A_FOOL__ "/'
    mv libtool-2 libtool
    chmod 755 libtool
    ;;
esac
