# ===========================================================================
#   http://www.gnu.org/software/autoconf-archive/ax_gcc_func_attribute.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_GCC_FUNC_ATTRIBUTE(ATTRIBUTE)
#
# DESCRIPTION
#
#   This macro checks if the compiler supports one of GCC's function
#   attributes; many other compilers (e.g., Clang, ICC) also provide
#   function attributes with the same syntax. Compiler warnings are used to
#   detect supported attributes, as unsupported ones are ignored by default.
#   To avoid false positives, ensure warnings are enabled (e.g., -Werror or
#   -Wall) when using this macro.
#
#   The ATTRIBUTE parameter holds the name of the attribute to be checked
#   (e.g., 'noreturn', 'visibility').
#
#   If ATTRIBUTE is supported, defines HAVE_FUNC_ATTRIBUTE_<ATTRIBUTE> (e.g.,
#   HAVE_FUNC_ATTRIBUTE_NORETURN).
#
#   The macro caches its result in ax_cv_have_func_attribute_<attribute>.
#
#   Supported attributes include:
#
#    alias, aligned, alloc_size, always_inline, artificial, assume, cold,
#    const, constructor, deprecated, destructor, dllexport, dllimport, error,
#    externally_visible, flatten, format, format_arg, gnu_inline, hot, ifunc,
#    leaf, likely, malloc, noclone, noinline, nonnull, noreturn, nothrow,
#    optimize, pure, unused, used, visibility, warning, warn_unused_result,
#    weak, weakref
#
#   Unsupported attributes are tested with a simple int-returning function
#   with no arguments, which may yield inaccurate results; use with caution.
#
# LICENSE
#
#   Copyright (c) 2013 Gabriele Svelto <gabriele.svelto@gmail.com>
#   Copyright (c) 2025 xAI (updates and enhancements)
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 8

AC_DEFUN([AX_GCC_FUNC_ATTRIBUTE], [
  AS_VAR_PUSHDEF([ac_var], [ax_cv_have_func_attribute_$1])
  AC_CACHE_CHECK([whether $CC supports __attribute__(($1))], [ac_var], [
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([
      m4_case([$1],
        [alias], [
          int foo(void) { return 0; }
          int bar(void) __attribute__(($1("foo")));
        ],
        [aligned], [
          int foo(void) __attribute__(($1(16)));
        ],
        [alloc_size], [
          void *foo(size_t n) __attribute__(($1(1)));
        ],
        [always_inline], [
          inline int foo(void) __attribute__(($1)) { return 0; }
        ],
        [artificial], [
          inline int foo(void) __attribute__(($1)) { return 0; }
        ],
        [assume], [
          int foo(int x) { __attribute__(($1(x > 0))); return x; }
        ],
        [cold], [
          int foo(void) __attribute__(($1));
        ],
        [const], [
          int foo(void) __attribute__(($1));
        ],
        [constructor], [
          int foo(void) __attribute__(($1));
        ],
        [deprecated], [
          int foo(void) __attribute__(($1("use something else")));
        ],
        [destructor], [
          int foo(void) __attribute__(($1));
        ],
        [dllexport], [
          __attribute__(($1)) int foo(void) { return 0; }
        ],
        [dllimport], [
          int foo(void) __attribute__(($1));
        ],
        [error], [
          int foo(void) __attribute__(($1("do not call")));
        ],
        [externally_visible], [
          int foo(void) __attribute__(($1));
        ],
        [flatten], [
          int foo(void) __attribute__(($1));
        ],
        [format], [
          int foo(const char *fmt, ...) __attribute__(($1(printf, 1, 2)));
        ],
        [format_arg], [
          const char *foo(const char *s) __attribute__(($1(1)));
        ],
        [gnu_inline], [
          inline int foo(void) __attribute__(($1)) { return 0; }
        ],
        [hot], [
          int foo(void) __attribute__(($1));
        ],
        [ifunc], [
          int my_foo(void) { return 0; }
          static int (*resolve_foo(void))(void) { return my_foo; }
          int foo(void) __attribute__(($1("resolve_foo")));
        ],
        [leaf], [
          int foo(void) __attribute__(($1));
        ],
        [likely], [
          int foo(int x) { if (__attribute__((likely)) (x > 0)) return 1; return 0; }
        ],
        [malloc], [
          void *foo(size_t n) __attribute__(($1));
        ],
        [noclone], [
          int foo(void) __attribute__(($1));
        ],
        [noinline], [
          int foo(void) __attribute__(($1)) { return 0; }
        ],
        [nonnull], [
          int foo(char *p) __attribute__(($1(1)));
        ],
        [noreturn], [
          void foo(void) __attribute__(($1));
        ],
        [nothrow], [
          int foo(void) __attribute__(($1));
        ],
        [optimize], [
          int foo(void) __attribute__(($1("O3"))) { return 0; }
        ],
        [pure], [
          int foo(int x) __attribute__(($1)) { return x; }
        ],
        [unused], [
          int foo(void) __attribute__(($1));
        ],
        [used], [
          static int foo(void) __attribute__(($1)) { return 0; }
        ],
        [visibility], [
          int foo(void) __attribute__(($1("default")));
        ],
        [warning], [
          int foo(void) __attribute__(($1("call me not")));
        ],
        [warn_unused_result], [
          int foo(void) __attribute__(($1));
        ],
        [weak], [
          int foo(void) __attribute__(($1));
        ],
        [weakref], [
          static int foo(void) { return 0; }
          static int bar(void) __attribute__(($1("foo")));
        ],
        [
          m4_warn([syntax], [Unsupported attribute `$1', result may be unreliable])
          int foo(void) __attribute__(($1));
        ]
      )], [int x = foo();])],
      [
        dnl Check for warnings in conftest.err; GCC ignores unknown attributes silently
        AC_RUN_IFELSE([AC_LANG_PROGRAM([[]], [[]])],
          [AS_IF([test -s conftest.err && grep -q "warning" conftest.err],
                 [AS_VAR_SET([ac_var], [no])],
                 [AS_VAR_SET([ac_var], [yes])])],
          [AS_VAR_SET([ac_var], [yes])])
      ],
      [AS_VAR_SET([ac_var], [no])])
  ])

  AS_IF([test "x"AS_VAR_GET([ac_var]) = "xyes"],
    [AC_DEFINE_UNQUOTED([HAVE_FUNC_ATTRIBUTE_]AS_TR_CPP([$1]), [1],
      [Define to 1 if the compiler supports the `$1' function attribute])],
    [])

  AS_VAR_POPDEF([ac_var])
])
