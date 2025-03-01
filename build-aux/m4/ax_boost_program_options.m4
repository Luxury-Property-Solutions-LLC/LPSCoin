# ============================================================================
#  http://www.gnu.org/software/autoconf-archive/ax_boost_program_options.html
# ============================================================================
#
# SYNOPSIS
#
#   AX_BOOST_PROGRAM_OPTIONS
#
# DESCRIPTION
#
#   Test for the Program Options library from the Boost C++ libraries. Requires
#   a preceding call to AX_BOOST_BASE. Used by LPSCoin Core for command-line
#   argument parsing in tools like lpscoinsd and lpscoins-cli. Further
#   documentation is available at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB)
#
#   And sets:
#
#     HAVE_BOOST_PROGRAM_OPTIONS
#
# LICENSE
#
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 22

AC_DEFUN([AX_BOOST_PROGRAM_OPTIONS],
[
AC_ARG_WITH([boost-program-options],
  [AS_HELP_STRING([--with-boost-program-options@<:@=special-lib@:>@],
    [use Boost Program Options library, optionally specifying a linker library
     (e.g., --with-boost-program-options=boost_program_options-gcc-mt-1_33_1);
     default is yes])],
    [if test "$withval" = "no"; then
         want_boost="no"
     elif test "$withval" = "yes"; then
         want_boost="yes"
         ax_boost_user_program_options_lib=""
     else
         want_boost="yes"
         ax_boost_user_program_options_lib="$withval"
     fi],
    [want_boost="yes"])

AC_REQUIRE([AX_BOOST_BASE])
if test "x$want_boost" = "xyes"; then
    AC_REQUIRE([AC_PROG_CC])
    CPPFLAGS_SAVED="$CPPFLAGS"
    CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
    export CPPFLAGS
    LDFLAGS_SAVED="$LDFLAGS"
    LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
    export LDFLAGS

    AC_CACHE_CHECK([whether the Boost::Program_Options library is available],
                   [ax_cv_boost_program_options],
    [AC_LANG_PUSH([C++])
     CXXFLAGS_SAVED=$CXXFLAGS
     AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <boost/program_options.hpp>]],
                                        [[boost::program_options::options_description generic("Generic options");
                                          return 0;]])],
                       [ax_cv_boost_program_options=yes], [ax_cv_boost_program_options=no])
     CXXFLAGS=$CXXFLAGS_SAVED
     AC_LANG_POP([C++])])

    if test "x$ax_cv_boost_program_options" = "xyes"; then
        AC_DEFINE(HAVE_BOOST_PROGRAM_OPTIONS,,[Define if the Boost::Program_Options library is available])
        BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
        ax_lib=
        if test "x$ax_boost_user_program_options_lib" = "x"; then
            for libextension in `find $BOOSTLIBDIR -name 'libboost_program_options*.so*' -o -name 'libboost_program_options*.dylib*' -o -name 'libboost_program_options*.a*' 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'`; do
                ax_lib=${libextension}
                AC_CHECK_LIB($ax_lib, boost::program_options::parse_config_file,
                             [BOOST_PROGRAM_OPTIONS_LIB="-l$ax_lib"; AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB); link_program_options="yes"; break],
                             [link_program_options="no"])
            done
            if test "x$link_program_options" != "xyes"; then
                for libextension in `find $BOOSTLIBDIR -name 'boost_program_options*.dll*' -o -name 'boost_program_options*.a*' 2>/dev/null | sed 's,.*/,,' | sed -e 's,\..*,,'`; do
                    ax_lib=${libextension}
                    AC_CHECK_LIB($ax_lib, boost::program_options::parse_config_file,
                                 [BOOST_PROGRAM_OPTIONS_LIB="-l$ax_lib"; AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB); link_program_options="yes"; break],
                                 [link_program_options="no"])
                done
            fi
        else
            for ax_lib in $ax_boost_user_program_options_lib boost_program_options-$ax_boost_user_program_options_lib; do
                AC_CHECK_LIB($ax_lib, boost::program_options::parse_config_file,
                             [BOOST_PROGRAM_OPTIONS_LIB="-l$ax_lib"; AC_SUBST(BOOST_PROGRAM_OPTIONS_LIB); link_program_options="yes"; break],
                             [link_program_options="no"])
            done
        fi

        if test "x$ax_lib" = "x"; then
            AC_MSG_ERROR([Could not find Boost Program Options library in $BOOSTLIBDIR])
        fi
        if test "x$link_program_options" = "xno"; then
            AC_MSG_ERROR([Could not link against Boost Program Options library ($ax_lib)])
        fi
    fi

    CPPFLAGS="$CPPFLAGS_SAVED"
    LDFLAGS="$LDFLAGS_SAVED"
fi
])
