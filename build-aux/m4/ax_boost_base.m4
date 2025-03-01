# ===========================================================================
#       http://www.gnu.org/software/autoconf-archive/ax_boost_base.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_BASE([MINIMUM-VERSION], [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#
#   Test for the Boost C++ libraries of a particular version (or newer).
#   Used by LPSCoin Core to detect Boost for features like Coin Mixing and
#   FastSend. If no path is given, searches /usr, /usr/local, /opt, and
#   /opt/local, and evaluates $BOOST_ROOT. See
#   <http://randspringer.de/boost/index.html> for more documentation.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_CPPFLAGS) / AC_SUBST(BOOST_LDFLAGS)
#
#   And sets:
#
#     HAVE_BOOST
#
# LICENSE
#
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2009 Peter Adolphs
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 23

AC_DEFUN([AX_BOOST_BASE],
[
AC_ARG_WITH([boost],
  [AS_HELP_STRING([--with-boost@<:@=ARG@:>@],
    [use Boost library from a standard location (ARG=yes),
     from the specified location (ARG=<path>),
     or disable it (ARG=no)
     @<:@ARG=yes@:>@])],
    [if test "$withval" = "no"; then
        want_boost="no"
     elif test "$withval" = "yes"; then
        want_boost="yes"
        ac_boost_path=""
     else
        want_boost="yes"
        ac_boost_path="$withval"
     fi],
    [want_boost="yes"])

AC_ARG_WITH([boost-libdir],
  [AS_HELP_STRING([--with-boost-libdir=LIB_DIR],
    [Force given directory for Boost libraries; overrides detection])],
    [if test -d "$withval"; then
         ac_boost_lib_path="$withval"
     else
         AC_MSG_ERROR([--with-boost-libdir expected a directory path])
     fi],
    [ac_boost_lib_path=""])

if test "x$want_boost" = "xyes"; then
    boost_lib_version_req=m4_if([$1], [], [1.20.0], [$1])
    boost_lib_version_req_shorten=`expr "$boost_lib_version_req" : '\([0-9]*\.[0-9]*\)' || echo "0.0"`
    boost_lib_version_req_major=`expr "$boost_lib_version_req" : '\([0-9]*\)' || echo 0`
    boost_lib_version_req_minor=`expr "$boost_lib_version_req" : '[0-9]*\.\([0-9]*\)' || echo 0`
    boost_lib_version_req_sub_minor=`expr "$boost_lib_version_req" : '[0-9]*\.[0-9]*\.\([0-9]*\)' || echo 0`
    if test "x$boost_lib_version_req_sub_minor" = "x"; then
        boost_lib_version_req_sub_minor="0"
    fi
    WANT_BOOST_VERSION=`expr $boost_lib_version_req_major \* 100000 + $boost_lib_version_req_minor \* 100 + $boost_lib_version_req_sub_minor`
    AC_MSG_CHECKING([for boostlib >= $boost_lib_version_req])
    succeeded=no

    # Define library subdirectories for multi-arch systems
    libsubdirs="lib"
    ax_arch=`uname -m 2>/dev/null || echo unknown`
    case $ax_arch in
      x86_64)
        libsubdirs="lib64 libx32 lib lib64"
        ;;
      ppc64|s390x|sparc64|aarch64)
        libsubdirs="lib64 lib lib64"
        ;;
    esac

    AC_REQUIRE([AC_CANONICAL_HOST])
    libsubdirs="lib/${host_cpu}-${host_os} $libsubdirs"
    case ${host_cpu} in
      i?86)
        libsubdirs="lib/i386-${host_os} $libsubdirs"
        ;;
    esac
    libsubdirs="lib/`$CXX -dumpmachine 2>/dev/null || echo unknown` $libsubdirs"

    # Check system locations first (for --layout=system or RPM installs)
    if test "$ac_boost_path" != ""; then
        BOOST_CPPFLAGS="-I$ac_boost_path/include"
        for ac_boost_path_tmp in $libsubdirs; do
            if test -d "$ac_boost_path/$ac_boost_path_tmp"; then
                BOOST_LDFLAGS="-L$ac_boost_path/$ac_boost_path_tmp"
                break
            fi
        done
    elif test "$cross_compiling" != "xyes"; then
        for ac_boost_path_tmp in /usr /usr/local /opt /opt/local; do
            if test -d "$ac_boost_path_tmp/include/boost" && test -r "$ac_boost_path_tmp/include/boost/version.hpp"; then
                for libsubdir in $libsubdirs; do
                    if test -e "$ac_boost_path_tmp/$libsubdir/libboost_system"* 2>/dev/null; then break; fi
                done
                BOOST_LDFLAGS="-L$ac_boost_path_tmp/$libsubdir"
                BOOST_CPPFLAGS="-I$ac_boost_path_tmp/include"
                break
            fi
        done
    else
        AC_MSG_WARN([Cross-compiling: Specify Boost path with --with-boost if not found])
    fi

    # Override LDFLAGS if --with-boost-libdir is set
    if test "$ac_boost_lib_path" != ""; then
        BOOST_LDFLAGS="-L$ac_boost_lib_path"
    fi

    CPPFLAGS_SAVED="$CPPFLAGS"
    CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
    export CPPFLAGS

    LDFLAGS_SAVED="$LDFLAGS"
    LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
    export LDFLAGS

    AC_REQUIRE([AC_PROG_CXX])
    AC_LANG_PUSH([C++])
    # Preliminary check for boost/version.hpp existence
    AC_CHECK_HEADER([boost/version.hpp], [],
                    [AC_MSG_ERROR([Boost header <boost/version.hpp> not found])])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <boost/version.hpp>]],
                                       [[#if BOOST_VERSION >= $WANT_BOOST_VERSION
                                         // Everything is okay
                                         #else
                                         #  error Boost version is too old
                                         #endif]])],
                      [AC_MSG_RESULT([yes])
                       succeeded=yes
                       found_system=yes],
                      [:])
    AC_LANG_POP([C++])

    # Search for non-system layout or staged Boost if system check fails
    # Note: Boost can be header-only; library presence is optional
    if test "x$succeeded" != "xyes"; then
        _version=0
        if test "$ac_boost_path" != ""; then
            if test -d "$ac_boost_path" && test -r "$ac_boost_path"; then
                for i in `ls -d $ac_boost_path/include/boost-* 2>/dev/null`; do
                    _version_tmp=`echo $i | sed "s#$ac_boost_path##" | sed 's/\/include\/boost-//' | sed 's/_/./'`
                    V_CHECK=`expr "$_version_tmp" \> "$_version" || echo 0`
                    if test "$V_CHECK" = "1"; then
                        _version=$_version_tmp
                    fi
                    VERSION_UNDERSCORE=`echo $_version | sed 's/\./_/'`
                    BOOST_CPPFLAGS="-I$ac_boost_path/include/boost-$VERSION_UNDERSCORE"
                done
            fi
        else
            if test "$cross_compiling" != "yes"; then
                for ac_boost_path in /usr /usr/local /opt /opt/local; do
                    if test -d "$ac_boost_path" && test -r "$ac_boost_path"; then
                        for i in `ls -d $ac_boost_path/include/boost-* 2>/dev/null`; do
                            _version_tmp=`echo $i | sed "s#$ac_boost_path##" | sed 's/\/include\/boost-//' | sed 's/_/./'`
                            V_CHECK=`expr "$_version_tmp" \> "$_version" || echo 0`
                            if test "$V_CHECK" = "1"; then
                                _version=$_version_tmp
                                best_path=$ac_boost_path
                            fi
                        done
                    fi
                done

                VERSION_UNDERSCORE=`echo $_version | sed 's/\./_/'`
                BOOST_CPPFLAGS="-I$best_path/include/boost-$VERSION_UNDERSCORE"
                if test "$ac_boost_lib_path" = ""; then
                    for libsubdir in $libsubdirs; do
                        if test -e "$best_path/$libsubdir/libboost_system"* 2>/dev/null; then break; fi
                    done
                    BOOST_LDFLAGS="-L$best_path/$libsubdir"
                fi
            fi

            if test "x$BOOST_ROOT" != "x"; then
                for libsubdir in $libsubdirs; do
                    if test -e "$BOOST_ROOT/stage/$libsubdir/libboost_system"* 2>/dev/null; then break; fi
                done
                if test -d "$BOOST_ROOT" && test -r "$BOOST_ROOT" && test -d "$BOOST_ROOT/stage/$libsubdir" && test -r "$BOOST_ROOT/stage/$libsubdir"; then
                    version_dir=`expr "//$BOOST_ROOT" : '.*/\(.*\)'`
                    stage_version=`echo $version_dir | sed 's/boost_//' | sed 's/_/./g'`
                    stage_version_shorten=`expr "$stage_version" : '\([0-9]*\.[0-9]*\)' || echo "0.0"`
                    V_CHECK=`expr "$stage_version_shorten" \>= "$_version" || echo 0`
                    if test "$V_CHECK" = "1" && test "$ac_boost_lib_path" = ""; then
                        AC_MSG_NOTICE([Using staged Boost library from $BOOST_ROOT])
                        BOOST_CPPFLAGS="-I$BOOST_ROOT"
                        BOOST_LDFLAGS="-L$BOOST_ROOT/stage/$libsubdir"
                    fi
                fi
            fi
        fi

        CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
        export CPPFLAGS
        LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
        export LDFLAGS

        AC_LANG_PUSH([C++])
        AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <boost/version.hpp>]],
                                           [[#if BOOST_VERSION >= $WANT_BOOST_VERSION
                                             // Everything is okay
                                             #else
                                             #  error Boost version is too old
                                             #endif]])],
                          [AC_MSG_RESULT([yes])
                           succeeded=yes
                           found_system=yes],
                          [:])
        AC_LANG_POP([C++])
    fi

    if test "$succeeded" != "yes"; then
        if test "$_version" = "0"; then
            AC_MSG_NOTICE([[Could not detect Boost libraries (version $boost_lib_version_req_shorten or higher). Set \$BOOST_ROOT for staged libraries or check <boost/version.hpp>. See http://randspringer.de/boost.]])
        else
            AC_MSG_NOTICE([Boost libraries too old (version $_version; need $boost_lib_version_req_shorten or higher).])
        fi
        ifelse([$3], , :, [$3])
    else
        AC_SUBST(BOOST_CPPFLAGS)
        AC_SUBST(BOOST_LDFLAGS)
        AC_DEFINE(HAVE_BOOST,,[Define if the Boost library is available])
        ifelse([$2], , :, [$2])
    fi

    CPPFLAGS="$CPPFLAGS_SAVED"
    LDFLAGS="$LDFLAGS_SAVED"
fi
])
