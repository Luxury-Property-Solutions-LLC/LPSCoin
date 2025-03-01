# ===========================================================================
#      http://www.gnu.org/software/autoconf-archive/ax_boost_thread.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_THREAD
#
# DESCRIPTION
#
#   Test for Thread library from the Boost C++ libraries. The macro requires
#   a preceding call to AX_BOOST_BASE. Further documentation is available at
#   <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_THREAD_LIB)
#
#   And sets:
#
#     HAVE_BOOST_THREAD
#
# LICENSE
#
#   Copyright (c) 2009 Thomas Porschberg <thomas@randspringer.de>
#   Copyright (c) 2009 Michael Tindal
#   Copyright (c) 2025 xAI (updates and enhancements)
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 28

AC_DEFUN([AX_BOOST_THREAD],
[
	AC_ARG_WITH([boost-thread],
	AS_HELP_STRING([--with-boost-thread@<:@=special-lib@:>@],
                   [use the Thread library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-thread=boost_thread-gcc-mt ]),
        [
        if test "$withval" = "no"; then
			want_boost="no"
        elif test "$withval" = "yes"; then
            want_boost="yes"
            ax_boost_user_thread_lib=""
        else
		    want_boost="yes"
		    ax_boost_user_thread_lib="$withval"
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

        AC_CACHE_CHECK([whether the Boost::Thread library is available],
					   ax_cv_boost_thread,
        [AC_LANG_PUSH([C++])
			 CXXFLAGS_SAVE="$CXXFLAGS"
			 if test "x$host_os" = "xsolaris" ; then
				 CXXFLAGS="-pthreads -std=c++11 $CXXFLAGS"
			 elif test "x$host_os" = "xmingw32" ; then
				 CXXFLAGS="-mthreads -std=c++11 $CXXFLAGS"
			 else
				 CXXFLAGS="-pthread -std=c++11 $CXXFLAGS"
			 fi
			 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[@%:@include <boost/thread/thread.hpp>]],
                                   [[boost::thread_group thrds; return 0;]])],
                   ax_cv_boost_thread=yes, ax_cv_boost_thread=no)
			 CXXFLAGS="$CXXFLAGS_SAVE"
             AC_LANG_POP([C++])
		])
		if test "x$ax_cv_boost_thread" = "xyes"; then
			# Apply threading flags consistently
			if test "x$host_os" = "xsolaris" ; then
				BOOST_CPPFLAGS="-pthreads $BOOST_CPPFLAGS"
			elif test "x$host_os" = "xmingw32" ; then
				BOOST_CPPFLAGS="-mthreads $BOOST_CPPFLAGS"
			else
				BOOST_CPPFLAGS="-pthread $BOOST_CPPFLAGS"
			fi

			AC_SUBST(BOOST_CPPFLAGS)
			AC_DEFINE(HAVE_BOOST_THREAD,,[define if the Boost::Thread library is available])

			BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`
			if test "x$BOOSTLIBDIR" = "x"; then
				AC_MSG_ERROR([BOOSTLIBDIR is not set. Ensure AX_BOOST_BASE is called and --with-boost-libdir is correct.])
			fi

			LDFLAGS_SAVE="$LDFLAGS"
			case "x$host_os" in
				*bsd*)
					LDFLAGS="-pthread $LDFLAGS"
					;;
			esac

			if test "x$ax_boost_user_thread_lib" = "x"; then
				ax_lib=
				for libextension in `ls -r $BOOSTLIBDIR/libboost_thread* 2>/dev/null | sed 's,.*/lib,,' | sed 's,\..*,,'`; do
					ax_lib=${libextension}
					AC_LANG_PUSH([C++])
					AC_CHECK_LIB($ax_lib, _ZN5boost12thread_group4sizeEv,  # Mangled name for boost::thread_group::size()
								 [BOOST_THREAD_LIB="-l$ax_lib"; AC_SUBST(BOOST_THREAD_LIB) link_thread="yes"; break],
								 [link_thread="no"],
								 [$BOOST_LDFLAGS])
					AC_LANG_POP([C++])
				done
				if test "x$link_thread" != "xyes"; then
					for libextension in `ls -r $BOOSTLIBDIR/boost_thread* 2>/dev/null | sed 's,.*/,,' | sed -e 's,\..*,,'`; do
						ax_lib=${libextension}
						AC_LANG_PUSH([C++])
						AC_CHECK_LIB($ax_lib, _ZN5boost12thread_group4sizeEv,
									 [BOOST_THREAD_LIB="-l$ax_lib"; AC_SUBST(BOOST_THREAD_LIB) link_thread="yes"; break],
									 [link_thread="no"],
									 [$BOOST_LDFLAGS])
						AC_LANG_POP([C++])
					done
				fi
			else
				for ax_lib in $ax_boost_user_thread_lib boost_thread-$ax_boost_user_thread_lib; do
					AC_LANG_PUSH([C++])
					AC_CHECK_LIB($ax_lib, _ZN5boost12thread_group4sizeEv,
								 [BOOST_THREAD_LIB="-l$ax_lib"; AC_SUBST(BOOST_THREAD_LIB) link_thread="yes"; break],
								 [link_thread="no"],
								 [$BOOST_LDFLAGS])
					AC_LANG_POP([C++])
				done
			fi

			if test "x$ax_lib" = "x"; then
				AC_MSG_ERROR([Could not find Boost.Thread library in $BOOSTLIBDIR. Ensure Boost is installed and --with-boost points to the correct prefix.])
			fi
			if test "x$link_thread" = "xno"; then
				AC_MSG_ERROR([Could not link against $ax_lib in $BOOSTLIBDIR. Check library compatibility, linker flags, or Boost installation.])
			else
				case "x$host_os" in
					*bsd*)
						BOOST_LDFLAGS="-pthread $BOOST_LDFLAGS"
						;;
				esac
			fi
		else
			AC_MSG_WARN([Boost.Thread headers not found. Check BOOST_CPPFLAGS or Boost installation.])
		fi

		CPPFLAGS="$CPPFLAGS_SAVED"
		LDFLAGS="$LDFLAGS_SAVED"
	fi
])
