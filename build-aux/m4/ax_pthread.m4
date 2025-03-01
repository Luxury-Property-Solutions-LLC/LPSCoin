# ===========================================================================
#        http://www.gnu.org/software/autoconf-archive/ax_pthread.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_PTHREAD([ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]])
#
# DESCRIPTION
#
#   This macro determines how to build C programs using POSIX threads. It
#   sets PTHREAD_LIBS to the required thread library and linker flags,
#   PTHREAD_CFLAGS to any necessary compiler flags, and PTHREAD_CC to a
#   special compiler (e.g., cc_r on AIX) if needed (defaults to CC otherwise).
#
#   Users can override detection by setting PTHREAD_LIBS, PTHREAD_CFLAGS, or
#   PTHREAD_CC in the environment. The macro assumes these flags are used for
#   both compiling and linking (e.g., $PTHREAD_CC $CFLAGS $PTHREAD_CFLAGS
#   $LDFLAGS ... $PTHREAD_LIBS $LIBS).
#
#   For thread-only programs, consider adding to defaults:
#     LIBS="$PTHREAD_LIBS $LIBS"
#     CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
#     CC="$PTHREAD_CC"
#
#   Defines PTHREAD_CREATE_JOINABLE to a nonstandard name (e.g.,
#   PTHREAD_CREATE_UNDETACHED on AIX) if needed. Defines
#   HAVE_PTHREAD_PRIO_INHERIT if PTHREAD_PRIO_INHERIT is available with
#   PTHREAD_CFLAGS.
#
#   ACTION-IF-FOUND is executed if pthreads are found (default: defines
#   HAVE_PTHREAD); ACTION-IF-NOT-FOUND is executed otherwise.
#
# LICENSE
#
#   Copyright (c) 2008 Steven G. Johnson <stevenj@alum.mit.edu>
#   Copyright (c) 2011 Daniel Richard G. <skunk@iSKUNK.ORG>
#   Copyright (c) 2025 xAI (updates and enhancements)
#
#   This program is free software: you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.

#serial 28

AU_ALIAS([ACX_PTHREAD], [AX_PTHREAD])
AC_DEFUN([AX_PTHREAD], [
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_REQUIRE([AC_PROG_CC])
  AC_LANG_PUSH([C])

  ax_pthread_ok=no

  # Check user-provided flags first
  if test "x$PTHREAD_LIBS$PTHREAD_CFLAGS" != "x"; then
    save_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
    save_LIBS="$LIBS"
    LIBS="$PTHREAD_LIBS $LIBS"
    AC_MSG_CHECKING([for pthread_join with user-provided PTHREAD_LIBS=$PTHREAD_LIBS and PTHREAD_CFLAGS=$PTHREAD_CFLAGS])
    AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <pthread.h>], [pthread_join(0, 0);])],
      [ax_pthread_ok=yes],
      [PTHREAD_LIBS="" PTHREAD_CFLAGS=""])
    AC_MSG_RESULT([$ax_pthread_ok])
    LIBS="$save_LIBS"
    CFLAGS="$save_CFLAGS"
  fi

  # List of flags to try
  ax_pthread_flags="pthreads none -Kthread -kthread lthread -pthread -pthreads -mthreads pthread --thread-safe -mt pthread-config"

  case ${host_os} in
    solaris*)
      ax_pthread_flags="-pthreads pthread -mt -pthread $ax_pthread_flags"
      ;;
    darwin*)
      ax_pthread_flags="-pthread $ax_pthread_flags"
      ;;
    freebsd*)
      ax_pthread_flags="-kthread -pthread $ax_pthread_flags"
      ;;
    aix*)
      ax_pthread_flags="pthreads -pthread $ax_pthread_flags"
      ;;
  esac

  # Check if -Werror is needed for Clang to reject unknown flags
  AC_MSG_CHECKING([if compiler needs -Werror to reject unknown flags])
  save_CFLAGS="$CFLAGS"
  ax_pthread_extra_flags="-Werror"
  CFLAGS="$CFLAGS $ax_pthread_extra_flags -Wunknown-warning-option -Wsizeof-array-argument"
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([int foo(void);], [foo();])],
    [AC_MSG_RESULT([yes])],
    [ax_pthread_extra_flags="" AC_MSG_RESULT([no])])
  CFLAGS="$save_CFLAGS"

  if test "x$ax_pthread_ok" = "xno"; then
    for flag in $ax_pthread_flags; do
      case $flag in
        none)
          AC_MSG_CHECKING([whether pthreads work without any flags])
          ;;
        -*)
          AC_MSG_CHECKING([whether pthreads work with $flag])
          PTHREAD_CFLAGS="$flag"
          ;;
        pthread-config)
          AC_CHECK_PROG([ax_pthread_config], [pthread-config], [yes], [no])
          if test "x$ax_pthread_config" = "xno"; then continue; fi
          PTHREAD_CFLAGS="`pthread-config --cflags`"
          PTHREAD_LIBS="`pthread-config --ldflags` `pthread-config --libs`"
          ;;
        *)
          AC_MSG_CHECKING([for the pthreads library -l$flag])
          PTHREAD_LIBS="-l$flag"
          ;;
      esac

      save_LIBS="$LIBS"
      save_CFLAGS="$CFLAGS"
      LIBS="$PTHREAD_LIBS $LIBS"
      CFLAGS="$CFLAGS $PTHREAD_CFLAGS $ax_pthread_extra_flags"

      AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <pthread.h>
        static void routine(void *a) { a = 0; }
        static void *start_routine(void *a) { return a; }],
        [pthread_t th; pthread_attr_t attr;
         pthread_create(&th, 0, start_routine, 0);
         pthread_join(th, 0);
         pthread_attr_init(&attr);
         pthread_cleanup_push(routine, 0);
         pthread_cleanup_pop(0);])],
        [ax_pthread_ok=yes],
        [])

      AC_MSG_RESULT([$ax_pthread_ok])
      LIBS="$save_LIBS"
      CFLAGS="$save_CFLAGS"

      if test "x$ax_pthread_ok" = "xyes"; then
        break
      fi

      PTHREAD_LIBS=""
      PTHREAD_CFLAGS=""
    done
  fi

  # Additional checks if pthreads are found
  if test "x$ax_pthread_ok" = "xyes"; then
    save_LIBS="$LIBS"
    LIBS="$PTHREAD_LIBS $LIBS"
    save_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS $PTHREAD_CFLAGS"

    # Check for nonstandard PTHREAD_CREATE_JOINABLE
    AC_MSG_CHECKING([for joinable pthread attribute])
    attr_name=unknown
    for attr in PTHREAD_CREATE_JOINABLE PTHREAD_CREATE_UNDETACHED; do
      AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <pthread.h>], [int attr = $attr;])],
        [attr_name=$attr; break],
        [])
    done
    AC_MSG_RESULT([$attr_name])
    if test "x$attr_name" != "xPTHREAD_CREATE_JOINABLE"; then
      AC_DEFINE_UNQUOTED([PTHREAD_CREATE_JOINABLE], [$attr_name],
        [Define to necessary symbol if this constant uses a non-standard name on your system])
    fi

    # Platform-specific flags
    AC_MSG_CHECKING([for additional pthread flags])
    flag=no
    case ${host_os} in
      aix* | freebsd* | darwin*) flag="-D_THREAD_SAFE" ;;
      osf* | hpux*) flag="-D_REENTRANT" ;;
      solaris*)
        if test "x$GCC" = "xyes"; then
          flag="-D_REENTRANT"
        else
          flag="-mt -D_REENTRANT"
        fi
        ;;
      linux*) flag="-D_REENTRANT" ;;
    esac
    AC_MSG_RESULT([$flag])
    if test "x$flag" != "xno"; then
      PTHREAD_CFLAGS="$flag $PTHREAD_CFLAGS"
    fi

    # Check for PTHREAD_PRIO_INHERIT
    AC_CACHE_CHECK([for PTHREAD_PRIO_INHERIT],
      [ax_cv_PTHREAD_PRIO_INHERIT],
      [AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <pthread.h>], [int i = PTHREAD_PRIO_INHERIT;])],
        [ax_cv_PTHREAD_PRIO_INHERIT=yes],
        [ax_cv_PTHREAD_PRIO_INHERIT=no])])
    AS_IF([test "x$ax_cv_PTHREAD_PRIO_INHERIT" = "xyes"],
      [AC_DEFINE([HAVE_PTHREAD_PRIO_INHERIT], [1], [Define if PTHREAD_PRIO_INHERIT is available])])

    # AIX compiler variant
    if test "x$GCC" != "xyes"; then
      case ${host_os} in
        aix*)
          AS_CASE(["x/$CC"],
            [x*/c89|x*/c89_128|x*/c99|x*/c99_128|x*/cc|x*/cc128|x*/xlc|x*/xlc_v6|x*/xlc128|x*/xlc128_v6],
            [AS_IF([AS_EXECUTABLE_P([${CC}_r])], [PTHREAD_CC="${CC}_r"], [PTHREAD_CC="$CC"])])
          ;;
      esac
    fi

    LIBS="$save_LIBS"
    CFLAGS="$save_CFLAGS"
  fi

  test -n "$PTHREAD_CC" || PTHREAD_CC="$CC"

  AC_SUBST([PTHREAD_LIBS])
  AC_SUBST([PTHREAD_CFLAGS])
  AC_SUBST([PTHREAD_CC])

  # Execute actions
  AS_IF([test "x$ax_pthread_ok" = "xyes"],
    [ifelse([$1],, [AC_DEFINE([HAVE_PTHREAD], [1], [Define if POSIX threads are available])], [$1])],
    [ax_pthread_ok=no $2])
  AC_LANG_POP([C])
])dnl AX_PTHREAD
