# SYNOPSIS
#
#   BITCOIN_FIND_BDB48
#
# DESCRIPTION
#
#   This macro locates Berkeley DB (BDB) C++ headers and libraries, version
#   4.8 or higher, required for wallet functionality in Bitcoin-derived
#   projects like LPSCoin. It sets BDB_CPPFLAGS to include paths and
#   BDB_LIBS to linker flags.
#
#   The macro prefers BDB 4.8 exactly for wallet portability but allows
#   other versions (4.8+) with --with-incompatible-bdb. If BDB is not found
#   or incompatible, it fails unless --disable-wallet is specified.
#
#   Search paths include common prefixes (e.g., /usr/include/db4.8) and can
#   be influenced by --with-bdb-dir=PATH. Uses pkg-config if available.
#
# OUTPUT
#
#   Sets and substitutes BDB_CPPFLAGS and BDB_LIBS.

AC_DEFUN([BITCOIN_FIND_BDB48], [
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])

  AC_MSG_CHECKING([for Berkeley DB C++ headers (4.8+)])

  # Allow user to specify BDB location
  AC_ARG_WITH([bdb-dir],
    [AS_HELP_STRING([--with-bdb-dir=PATH], [specify Berkeley DB base directory])],
    [bdb_base_dir="$withval"],
    [bdb_base_dir=""])

  BDB_CPPFLAGS=""
  BDB_LIBS=""
  bdbpath="X"
  bdb48path="X"
  bdb_found=false

  # Common BDB directory patterns
  bdb_dir_list=""
  for vn in 4.8 48 4 5 ""; do
    for pfx in "" b lib; do
      bdb_dir_list="$bdb_dir_list ${pfx}db${vn}"
    done
  done

  # Add user-specified path to the front of the search list
  if test -n "$bdb_base_dir"; then
    bdb_dir_list="$bdb_base_dir/include $bdb_dir_list"
  fi

  # Try pkg-config first if available
  if test -n "$PKG_CONFIG"; then
    PKG_CHECK_MODULES([BDB], [libdb_cxx-4.8], [
      bdbpath=""
      bdb48path=""
      BDB_CPPFLAGS="$BDB_CFLAGS"
      BDB_LIBS="$BDB_LIBS"
      bdb_found=true
      AC_MSG_RESULT([yes (via pkg-config: libdb_cxx-4.8)])
    ], [
      PKG_CHECK_MODULES([BDB], [libdb_cxx], [
        bdbpath=""
        BDB_CPPFLAGS="$BDB_CFLAGS"
        BDB_LIBS="$BDB_LIBS"
        # Verify version via compile test below
      ], [])
    ])
  fi

  # Search for headers if pkg-config didn’t fully succeed
  if test "x$bdb_found" != "xtrue"; then
    for searchpath in $bdb_dir_list ""; do
      test -n "$searchpath" && searchpath="${searchpath}/"
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <${searchpath}db_cxx.h>
      ]], [[
        #if !((DB_VERSION_MAJOR == 4 && DB_VERSION_MINOR >= 8) || DB_VERSION_MAJOR > 4)
          #error "Berkeley DB version < 4.8"
        #endif
      ]])], [
        if test "x$bdbpath" = "xX"; then
          bdbpath="$searchpath"
        fi
      ], [continue])

      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
        #include <${searchpath}db_cxx.h>
      ]], [[
        #if !(DB_VERSION_MAJOR == 4 && DB_VERSION_MINOR == 8)
          #error "Berkeley DB version != 4.8"
        #endif
      ]])], [
        bdb48path="$searchpath"
        break
      ], [])
    done

    if test "x$bdbpath" = "xX"; then
      AC_MSG_RESULT([no])
      AC_MSG_ERROR([Berkeley DB C++ headers (4.8+) not found; use --with-bdb-dir or --disable-wallet])
    elif test "x$bdb48path" != "xX"; then
      BITCOIN_SUBDIR_TO_INCLUDE([BDB_CPPFLAGS], [${bdb48path}], [db_cxx])
      bdbpath="$bdb48path"
      AC_MSG_RESULT([yes (version 4.8 at ${bdb48path})])
    else
      BITCOIN_SUBDIR_TO_INCLUDE([BDB_CPPFLAGS], [${bdbpath}], [db_cxx])
      AC_ARG_WITH([incompatible-bdb],
        [AS_HELP_STRING([--with-incompatible-bdb], [allow non-4.8 BDB versions (wallets may not be portable)])],
        [AC_MSG_WARN([Using BDB version != 4.8 (${bdbpath}); wallets may not be portable])],
        [AC_MSG_ERROR([BDB version != 4.8 (${bdbpath}); use --with-incompatible-bdb or --disable-wallet])])
      AC_MSG_RESULT([yes (version != 4.8 at ${bdbpath})])
    fi
  fi

  AC_SUBST([BDB_CPPFLAGS])

  # Find the library if not set by pkg-config
  if test "x$BDB_LIBS" = "x"; then
    save_LIBS="$LIBS"
    save_CPPFLAGS="$CPPFLAGS"
    CPPFLAGS="$CPPFLAGS $BDB_CPPFLAGS"

    for searchlib in db_cxx-4.8 db_cxx; do
      AC_CHECK_LIB([$searchlib], [Db::open], [
        BDB_LIBS="-l${searchlib}"
        break
      ], [])
    done

    LIBS="$save_LIBS"
    CPPFLAGS="$save_CPPFLAGS"

    if test "x$BDB_LIBS" = "x"; then
      AC_MSG_ERROR([Berkeley DB C++ library not found; required for wallet functionality (--disable-wallet to bypass)])
    fi
  fi

  AC_SUBST([BDB_LIBS])
])

# Helper macro to construct include flags
AC_DEFUN([BITCOIN_SUBDIR_TO_INCLUDE], [
  ifelse([$2], [], [m4_fatal([BITCOIN_SUBDIR_TO_INCLUDE requires a subdir])])
  $1="-I${2}include"
  if test "x$2" != "x"; then
    $1="$1 -I${2}"
  fi
])
