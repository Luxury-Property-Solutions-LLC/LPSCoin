# ===========================================================================
#    http://www.gnu.org/software/autoconf-archive/ax_boost_filesystem.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_FILESYSTEM
#
# DESCRIPTION
#
#   Test for the Filesystem library from the Boost C++ libraries. Requires a
#   preceding call to AX_BOOST_BASE and AX_BOOST_SYSTEM. Used by LPSCoin Core
#   for file operations (e.g., blockchain data management). Further
#   documentation is available at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_FILESYSTEM_LIB)
#
#   And sets:
#
#     HAVE_BOOST_FILESYSTEM
#
# LICENSE
#
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2009 Michael Tindal
#   Copyright (c) 2009 Roman Rybalko <libtorrent@romanr.info>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 26

AC_DEFUN([AX_BOOST_FILESYSTEM],
[
AC_ARG_WITH([boost-filesystem],
  [AS_HELP_STRING([--with-boost-filesystem@<:@=special-lib@:>@],
    [use Boost Filesystem library, optionally specifying a linker library
     (e.g., --with-boost-filesystem=boost_filesystem-gcc-mt); default is yes])],
    [if test "$withval" = "no"; then
         want_boost="no"
     elif test "$withval" = "yes"; then
         want_boost="yes"
         ax_boost_user_filesystem_lib=""
     else
         want_boost="yes"
         ax_boost_user_filesystem_lib="$withval"
     fi],
    [want_boost="yes"])

AC_REQUIRE([AX_BOOST_BASE])
AC_REQUIRE([AX_BOOST_SYSTEM])
if test "x$want_boost" = "xyes"; then
    AC_REQUIRE([AC_PROG_CC])
    CPPFLAGS_SAVED="$CPPFLAGS"
    CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
    export CPPFLAGS

    LDFLAGS_SAVED="$LDFLAGS"
    LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
    export LDFLAGS

    LIBS_SAVED="$LIBS"
    LIBS="$LIBS $BOOST_SYSTEM_LIB"
    export LIBS

    AC_CACHE_CHECK([whether the Boost::Filesystem library is available],
                   [ax_cv_boost_filesystem],
    [AC_LANG_PUSH([C++])
     CXXFLAGS_SAVE=$CXXFLAGS
     AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <boost/filesystem/path.hpp>]],
                                        [[using namespace boost::filesystem;
                                          path my_path("foo/bar/data.txt");
                                          return 0;]])],
                       [ax_cv_boost_filesystem=yes], [ax_cv_boost_filesystem=no])
     CXXFLAGS=$CXXFLAGS_SAVE
     AC_LANG_POP([C++])])

    if test "x$ax_cv_boost_filesystem" = "xyes"; then
        AC_DEFINE(HAVE_BOOST_FILESYSTEM,,[Define if the Boost::Filesystem library is available])
        BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
        ax_lib=
        if test "x$ax_boost_user_filesystem_lib" = "x"; then
            for libextension in `find $BOOSTLIBDIR -name 'libboost_filesystem*' 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'`; do
                ax_lib=${libextension}
                AC_CHECK_LIB($ax_lib, boost::filesystem::exists,
                             [BOOST_FILESYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_FILESYSTEM_LIB); link_filesystem="yes"; break],
                             [link_filesystem="no"])
            done
            if test "x$link_filesystem" != "xyes"; then
                for libextension in `find $BOOSTLIBDIR -name 'boost_filesystem*' 2>/dev/null | sed 's,.*/,,' | sed -e 's,\..*,,'`; do
                    ax_lib=${libextension}
                    AC_CHECK_LIB($ax_lib, boost::filesystem::exists,
                                 [BOOST_FILESYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_FILESYSTEM_LIB); link_filesystem="yes"; break],
                                 [link_filesystem="no"])
                done
            fi
        else
            for ax_lib in $ax_boost_user_filesystem_lib boost_filesystem-$ax_boost_user_filesystem_lib; do
                AC_CHECK_LIB($ax_lib, boost::filesystem::exists,
                             [BOOST_FILESYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_FILESYSTEM_LIB); link_filesystem="yes"; break],
                             [link_filesystem="no"])
            done
        fi

        if test "x$ax_lib" = "x"; then
            AC_MSG_ERROR([Could not find Boost Filesystem library in $BOOSTLIBDIR])
        fi
        if test "x$link_filesystem" = "xno"; then
            AC_MSG_ERROR([Could not link against Boost Filesystem library ($ax_lib) with $BOOST_SYSTEM_LIB])
        fi
    fi

    CPPFLAGS="$CPPFLAGS_SAVED"
    LDFLAGS="$LDFLAGS_SAVED"
    LIBS="$LIBS_SAVED"
fi
])
