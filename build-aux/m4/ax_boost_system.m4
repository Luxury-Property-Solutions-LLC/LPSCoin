# ===========================================================================
#      http://www.gnu.org/software/autoconf-archive/ax_boost_system.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_SYSTEM
#
# DESCRIPTION
#
#   Test for System library from the Boost C++ libraries. The macro requires
#   a preceding call to AX_BOOST_BASE. Further documentation is available at
#   <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_SYSTEM_LIB)
#
#   And sets:
#
#     HAVE_BOOST_SYSTEM
#
# LICENSE
#
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2008 Michael Tindal
#   Copyright (c) 2008 Daniel Casimiro <dan.casimiro@gmail.com>
#   Copyright (c) 2025 xAI (updates and enhancements)
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 18

AC_DEFUN([AX_BOOST_SYSTEM],
[
	AC_ARG_WITH([boost-system],
	AS_HELP_STRING([--with-boost-system@<:@=special-lib@:>@],
                   [use the System library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-system=boost_system-gcc-mt ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_system_lib=""
        else
		    want_boost="yes"
		    ax_boost_user_system_lib="$withval"
		fi
        ],
        [want_boost="yes"]
	)

	if test "x$want_boost" = "xyes"; then
        AC_REQUIRE([AC_PROG_CC])
        AC_REQUIRE([AC_CANONICAL_BUILD])
		CPPFLAGS_SAVED="$CPPFLAGS"
		CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
		export CPPFLAGS

		LDFLAGS_SAVED="$LDFLAGS"
		LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
		export LDFLAGS

        AC_CACHE_CHECK([whether the Boost::System library is available],
					   ax_cv_boost_system,
        [AC_LANG_PUSH([C++])
			 CXXFLAGS_SAVE="$CXXFLAGS"
			 CXXFLAGS="$CXXFLAGS -std=c++11"  # Enforce C++11; adjust as needed
			 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/system/error_code.hpp>]],
                                   [[boost::system::system_category()]])],
                   ax_cv_boost_system=yes, ax_cv_boost_system=no)
			 CXXFLAGS="$CXXFLAGS_SAVE"
             AC_LANG_POP([C++])
		])
		if test "x$ax_cv_boost_system" = "xyes"; then
			AC_SUBST(BOOST_CPPFLAGS)
			AC_DEFINE(HAVE_BOOST_SYSTEM,,[define if the Boost::System library is available])

			BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
			if test "x$BOOSTLIBDIR" = "x"; then
				AC_MSG_ERROR([BOOSTLIBDIR is not set. Ensure AX_BOOST_BASE is called and --with-boost-libdir is correct.])
			fi

			LDFLAGS_SAVE="$LDFLAGS"
            if test "x$ax_boost_user_system_lib" = "x"; then
                ax_lib=
                for libextension in `ls -r $BOOSTLIBDIR/libboost_system* 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'` ; do
                     ax_lib=${libextension}
				    AC_LANG_PUSH([C++])
				    AC_CHECK_LIB($ax_lib, boost::system::system_category,
                                 [BOOST_SYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_SYSTEM_LIB) link_system="yes"; break],
                                 [link_system="no"],
                                 [$BOOST_LDFLAGS])
				    AC_LANG_POP([C++])
				done
                if test "x$link_system" != "xyes"; then
                    for libextension in `ls -r $BOOSTLIBDIR/boost_system* 2>/dev/null | sed 's,.*/,,' | sed -e 's,\..*,,'` ; do
                         ax_lib=${libextension}
				        AC_LANG_PUSH([C++])
				        AC_CHECK_LIB($ax_lib, boost::system::system_category,
                                     [BOOST_SYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_SYSTEM_LIB) link_system="yes"; break],
                                     [link_system="no"],
                                     [$BOOST_LDFLAGS])
				        AC_LANG_POP([C++])
				    done
                fi
            else
               for ax_lib in $ax_boost_user_system_lib boost_system-$ax_boost_user_system_lib; do
				      AC_LANG_PUSH([C++])
				      AC_CHECK_LIB($ax_lib, boost::system::system_category,
                                   [BOOST_SYSTEM_LIB="-l$ax_lib"; AC_SUBST(BOOST_SYSTEM_LIB) link_system="yes"; break],
                                   [link_system="no"],
                                   [$BOOST_LDFLAGS])
				      AC_LANG_POP([C++])
                  done
            fi

            if test "x$ax_lib" = "x"; then
                AC_MSG_ERROR([Could not find Boost.System library in $BOOSTLIBDIR. Ensure Boost is installed and --with-boost points to the correct prefix.])
            fi
			if test "x$link_system" = "xno"; then
				AC_MSG_ERROR([Could not link against $ax_lib in $BOOSTLIBDIR. Check library compatibility, linker flags, or Boost installation.])
			fi
		else
			AC_MSG_WARN([Boost.System headers not found. Check BOOST_CPPFLAGS or Boost installation.])
		fi

		CPPFLAGS="$CPPFLAGS_SAVED"
		LDFLAGS="$LDFLAGS_SAVED"
	fi
])
