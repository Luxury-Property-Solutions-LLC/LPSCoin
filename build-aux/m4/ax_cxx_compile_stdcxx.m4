# ===========================================================================
#   http://www.gnu.org/software/autoconf-archive/ax_cxx_compile_stdcxx.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CXX_COMPILE_STDCXX(VERSION, [ext|noext], [mandatory|optional])
#
# DESCRIPTION
#
#   Check for baseline language coverage in the compiler for the specified
#   version of the C++ standard. If necessary, add switches to CXX and
#   CXXCPP to enable support. VERSION may be '11', '14', '17', '20', or '23'
#   (for C++11, C++14, C++17, C++20, or C++23 standards, respectively).
#
#   The second argument, if specified, indicates whether you insist on an
#   extended mode (e.g., -std=gnu++11) or a strict conformance mode (e.g.,
#   -std=c++11). If neither is specified, you get whatever works, with
#   preference for an extended mode.
#
#   The third argument, if specified 'mandatory' or if left unspecified,
#   indicates that baseline support for the specified C++ standard is
#   required and that the macro should error out if no mode with that
#   support is found. If specified 'optional', configuration proceeds
#   regardless, defining HAVE_CXX${VERSION} if and only if support is found.
#
# LICENSE
#
#   Copyright (c) 2008 Benjamin Kosnik <bkoz@redhat.com>
#   Copyright (c) 2012 Zack Weinberg <zackw@panix.com>
#   Copyright (c) 2013 Roy Stogner <roystgnr@ices.utexas.edu>
#   Copyright (c) 2014, 2015 Google Inc.; contributed by Alexey Sokolov <sokolov@google.com>
#   Copyright (c) 2015 Paul Norman <penorman@mac.com>
#   Copyright (c) 2015 Moritz Klammler <moritz@klammler.eu>
#   Copyright (c) 2016, 2018 Krzesimir Nowak <qdlacz@gmail.com>
#   Copyright (c) 2025 xAI (updates and enhancements)
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 16

AC_DEFUN([AX_CXX_COMPILE_STDCXX], [dnl
  m4_if([$1], [11], [], [$1], [14], [], [$1], [17], [], [$1], [20], [], [$1], [23], [],
        [m4_fatal([invalid first argument `$1' to AX_CXX_COMPILE_STDCXX; must be 11, 14, 17, 20, or 23])])dnl
  m4_if([$2], [], [], [$2], [ext], [], [$2], [noext], [],
        [m4_fatal([invalid second argument `$2' to AX_CXX_COMPILE_STDCXX; must be ext or noext])])dnl
  m4_if([$3], [], [ax_cxx_compile_cxx$1_required=true],
        [$3], [mandatory], [ax_cxx_compile_cxx$1_required=true],
        [$3], [optional], [ax_cxx_compile_cxx$1_required=false],
        [m4_fatal([invalid third argument `$3' to AX_CXX_COMPILE_STDCXX; must be mandatory or optional])])
  AC_LANG_PUSH([C++])dnl
  ac_success=no

  AC_CACHE_CHECK([whether $CXX supports C++$1 features by default],
    [ax_cv_cxx_compile_cxx$1],
    [AC_COMPILE_IFELSE([AC_LANG_SOURCE([_AX_CXX_COMPILE_STDCXX_testbody_$1])],
      [ax_cv_cxx_compile_cxx$1=yes],
      [ax_cv_cxx_compile_cxx$1=no])])
  if test x"$ax_cv_cxx_compile_cxx$1" = xyes; then
    ac_success=yes
  fi

  m4_if([$2], [noext], [], [dnl
  if test x"$ac_success" = xno; then
    for switch in -std=gnu++$1 -std=gnu++0x -std=gnu++2a -std=gnu++2b; do
      cachevar=AS_TR_SH([ax_cv_cxx_compile_cxx$1_$switch])
      AC_CACHE_CHECK([whether $CXX supports C++$1 features with $switch],
        [$cachevar],
        [ac_save_CXX="$CXX"
         CXX="$CXX $switch"
         AC_COMPILE_IFELSE([AC_LANG_SOURCE([_AX_CXX_COMPILE_STDCXX_testbody_$1])],
          [eval "$cachevar=yes"],
          [eval "$cachevar=no"])
         CXX="$ac_save_CXX"])
      if eval test x"\$$cachevar" = xyes; then
        CXX="$CXX $switch"
        if test -n "$CXXCPP"; then
          CXXCPP="$CXXCPP $switch"
        fi
        ac_success=yes
        break
      fi
    done
  fi])

  m4_if([$2], [ext], [], [dnl
  if test x"$ac_success" = xno; then
    for switch in -std=c++$1 -std=c++0x -std=c++2a -std=c++2b +std=c++$1 "-h std=c++$1"; do
      cachevar=AS_TR_SH([ax_cv_cxx_compile_cxx$1_$switch])
      AC_CACHE_CHECK([whether $CXX supports C++$1 features with $switch],
        [$cachevar],
        [ac_save_CXX="$CXX"
         CXX="$CXX $switch"
         AC_COMPILE_IFELSE([AC_LANG_SOURCE([_AX_CXX_COMPILE_STDCXX_testbody_$1])],
          [eval "$cachevar=yes"],
          [eval "$cachevar=no"])
         CXX="$ac_save_CXX"])
      if eval test x"\$$cachevar" = xyes; then
        CXX="$CXX $switch"
        if test -n "$CXXCPP"; then
          CXXCPP="$CXXCPP $switch"
        fi
        ac_success=yes
        break
      fi
    done
  fi])

  AC_LANG_POP([C++])
  if test x"$ax_cxx_compile_cxx$1_required" = xtrue; then
    if test x"$ac_success" = xno; then
      AC_MSG_ERROR([*** A compiler with support for C++$1 language features is required.])
    fi
  fi
  if test x"$ac_success" = xyes; then
    AC_DEFINE([HAVE_CXX$1], [1], [Define if the compiler supports basic C++$1 syntax])
    HAVE_CXX$1=1
  else
    AC_MSG_NOTICE([No compiler with C++$1 support was found])
    HAVE_CXX$1=0
  fi
  AC_SUBST([HAVE_CXX$1])
])

# Test bodies for each C++ standard

m4_define([_AX_CXX_COMPILE_STDCXX_testbody_11],
  [_AX_CXX_COMPILE_STDCXX_testbody_new_in_11])

m4_define([_AX_CXX_COMPILE_STDCXX_testbody_14],
  [_AX_CXX_COMPILE_STDCXX_testbody_new_in_11
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_14])

m4_define([_AX_CXX_COMPILE_STDCXX_testbody_17],
  [_AX_CXX_COMPILE_STDCXX_testbody_new_in_11
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_14
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_17])

m4_define([_AX_CXX_COMPILE_STDCXX_testbody_20],
  [_AX_CXX_COMPILE_STDCXX_testbody_new_in_11
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_14
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_17
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_20])

m4_define([_AX_CXX_COMPILE_STDCXX_testbody_23],
  [_AX_CXX_COMPILE_STDCXX_testbody_new_in_11
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_14
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_17
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_20
   _AX_CXX_COMPILE_STDCXX_testbody_new_in_23])

# C++11 features
m4_define([_AX_CXX_COMPILE_STDCXX_testbody_new_in_11], [[
#ifndef __cplusplus
#error "This is not a C++ compiler"
#elif __cplusplus < 201103L
#error "This is not a C++11 compiler"
#else
namespace cxx11 {
  // Static assert
  template <typename T>
  struct check {
    static_assert(sizeof(int) <= sizeof(T), "not big enough");
  };

  // Final/override
  struct Base { virtual void f() {} };
  struct Derived : Base { virtual void f() override {} };

  // Double right angle brackets
  template <typename T> struct check {};
  typedef check<check<void>> double_type;

  // Decltype
  int f() { int a = 1; decltype(a) b = 2; return a + b; }

  // Auto and type deduction
  auto add(int a, float b) -> decltype(a + b) { return a + b; }

  // Noexcept
  int f() noexcept { return 0; }
  static_assert(noexcept(f()), "f() should be noexcept");

  // Constexpr
  constexpr int square(int x) { return x * x; }
  static_assert(square(5) == 25, "square(5) failed");

  // Rvalue references
  int g(int&&) { return 0; }

  // Uniform initialization
  struct Test { int x{42}; };
  static_assert(Test().x == 42, "uniform init failed");

  // Lambdas
  auto lambda = [](int x) { return x + 1; };
}
#endif
]])

# C++14 features
m4_define([_AX_CXX_COMPILE_STDCXX_testbody_new_in_14], [[
#ifndef __cplusplus
#error "This is not a C++ compiler"
#elif __cplusplus < 201402L
#error "This is not a C++14 compiler"
#else
namespace cxx14 {
  // Polymorphic lambdas
  auto poly = [](auto x) { return x; };
  static_assert(poly(42) == 42, "poly lambda failed");

  // Binary literals
  constexpr int bin = 0b1010;
  static_assert(bin == 10, "binary literal failed");

  // Generalized constexpr
  constexpr int sum(int x) { return x > 0 ? x + sum(x - 1) : 0; }
  static_assert(sum(3) == 6, "constexpr sum failed");

  // Lambda init capture
  int x = 5;
  auto cap = [y = x]() { return y; };
  static_assert(cap() == 5, "lambda capture failed");

  // Digit separators
  constexpr int big = 1'000'000;
  static_assert(big == 1000000, "digit separators failed");

  // Return type deduction
  auto deduce(int x) { return x; }
}
#endif
]])

# C++17 features
m4_define([_AX_CXX_COMPILE_STDCXX_testbody_new_in_17], [[
#ifndef __cplusplus
#error "This is not a C++ compiler"
#elif __cplusplus < 201703L
#error "This is not a C++17 compiler"
#else
namespace cxx17 {
  // Structured bindings
  int arr[2] = {1, 2};
  auto [a, b] = arr;
  static_assert(a == 1 && b == 2, "structured bindings failed");

  // If/switch init
  if (int x = 10; x > 0) { static_assert(x == 10, "if init failed"); }

  // Inline variables
  inline static const int k = 42;
  static_assert(k == 42, "inline variable failed");

  // Fold expressions
  template<typename... Ts> auto sum(Ts... ts) { return (ts + ...); }
  static_assert(sum(1, 2, 3) == 6, "fold expression failed");
}
#endif
]])

# C++20 features
m4_define([_AX_CXX_COMPILE_STDCXX_testbody_new_in_20], [[
#ifndef __cplusplus
#error "This is not a C++ compiler"
#elif __cplusplus < 202002L
#error "This is not a C++20 compiler"
#else
namespace cxx20 {
  // Concepts (basic check)
  template<typename T>
  concept Integral = requires(T t) { t + 1; };
  static_assert(Integral<int>, "concept failed");

  // Ranges (minimal check)
  #include <ranges>
  int arr[] = {1, 2, 3};
  auto view = std::ranges::take_view(arr, 2);
  static_assert(view[0] == 1, "ranges failed");

  // Constexpr virtual functions
  struct S { constexpr virtual int f() const { return 42; } };
  struct D : S { constexpr int f() const override { return 43; } };
  static_assert(D().f() == 43, "constexpr virtual failed");

  // [[no_unique_address]]
  struct Empty {};
  struct Data { [[no_unique_address]] Empty e; int x; };
  static_assert(sizeof(Data) == sizeof(int), "no_unique_address failed");
}
#endif
]])

# C++23 features
m4_define([_AX_CXX_COMPILE_STDCXX_testbody_new_in_23], [[
#ifndef __cplusplus
#error "This is not a C++ compiler"
#elif __cplusplus < 202302L
#error "This is not a C++23 compiler"
#else
namespace cxx23 {
  // Static reflection (placeholder; not fully standardized yet)
  #include <type_traits>
  static_assert(std::is_same_v<int, int>, "basic reflection check");

  // if consteval
  consteval int immediate() { return 42; }
  static_assert(immediate() == 42, "if consteval failed");

  // Multidimensional subscript operator
  struct Matrix {
    int data[2][2];
    constexpr int operator[](int i, int j) const { return data[i][j]; }
  };
  constexpr Matrix m{{{1, 2}, {3, 4}}};
  static_assert(m[1, 1] == 4, "multidim subscript failed");
}
#endif
]])
