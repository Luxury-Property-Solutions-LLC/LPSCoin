# SYNOPSIS
#
#   BITCOIN_QT_INIT
#   BITCOIN_QT_CONFIGURE([USE_PKGCONFIG], [PREFERRED_QT_VERSION])
#   BITCOIN_QT_FAIL([MESSAGE])
#   BITCOIN_QT_CHECK([IF_QT_ENABLED], [IF_QT_DISABLED])
#   BITCOIN_QT_PATH_PROGS([VAR], [PROGS], [PATH], [CONTINUE_IF_MISSING])
#
# DESCRIPTION
#
#   These macros configure Qt dependencies for building the LPSCoin GUI
#   (lpscoins-qt). BITCOIN_QT_INIT sets up input variables, while
#   BITCOIN_QT_CONFIGURE finds Qt libraries and tools. Helper macros assist
#   with conditional checks and tool discovery.
#
#   Supports Qt4, Qt5, and Qt6 (auto-detected or specified via --with-gui).
#   Sets variables like QT_INCLUDES, QT_LIBS, MOC, UIC, etc., and enables
#   features like DBus and static plugins as needed.

# Helper: Exit or disable Qt if a dependency fails
AC_DEFUN([BITCOIN_QT_FAIL], [
  if test "x$bitcoin_qt_want_version" = "xauto" && test "x$bitcoin_qt_force" != "xyes"; then
    if test "x$bitcoin_enable_qt" != "xno"; then
      AC_MSG_WARN([$1; lpscoins-qt frontend will not be built])
    fi
    bitcoin_enable_qt=no
    bitcoin_enable_qt_test=no
  else
    AC_MSG_ERROR([$1])
  fi
])

# Helper: Conditional check based on Qt enablement
AC_DEFUN([BITCOIN_QT_CHECK], [
  if test "x$bitcoin_enable_qt" != "xno" && test "x$bitcoin_qt_want_version" != "xno"; then
    $1
  else
    m4_ifval([$2], [$2], [true])
  fi
])

# Helper: Find Qt tools with optional custom path
AC_DEFUN([BITCOIN_QT_PATH_PROGS], [
  BITCOIN_QT_CHECK([
    if test "x$3" != "x"; then
      AC_PATH_PROGS([$1], [$2], [], [$3])
    else
      AC_PATH_PROGS([$1], [$2])
    fi
    if test "x$$1" = "x" && test "x$4" != "xyes"; then
      BITCOIN_QT_FAIL([$1 not found])
    fi
  ])
])

# Initialize Qt configuration
AC_DEFUN([BITCOIN_QT_INIT], [
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_ARG_WITH([gui],
    [AS_HELP_STRING([--with-gui@<:@=no|qt4|qt5|qt6|auto@:>@],
      [build lpscoins-qt GUI (default=auto, qt6 tried first)])],
    [
      bitcoin_qt_want_version="$withval"
      if test "x$bitcoin_qt_want_version" = "xyes"; then
        bitcoin_qt_force=yes
        bitcoin_qt_want_version=auto
      fi
    ],
    [bitcoin_qt_want_version=auto])

  AC_ARG_WITH([qt-incdir], [AS_HELP_STRING([--with-qt-incdir=DIR], [specify Qt include path])], [qt_include_path="$withval"], [])
  AC_ARG_WITH([qt-libdir], [AS_HELP_STRING([--with-qt-libdir=DIR], [specify Qt library path])], [qt_lib_path="$withval"], [])
  AC_ARG_WITH([qt-plugindir], [AS_HELP_STRING([--with-qt-plugindir=DIR], [specify Qt plugin path])], [qt_plugin_path="$withval"], [])
  AC_ARG_WITH([qt-translationdir], [AS_HELP_STRING([--with-qt-translationdir=DIR], [specify Qt translation path])], [qt_translation_path="$withval"], [])
  AC_ARG_WITH([qt-bindir], [AS_HELP_STRING([--with-qt-bindir=DIR], [specify Qt binary path])], [qt_bin_path="$withval"], [])

  AC_ARG_WITH([qtdbus],
    [AS_HELP_STRING([--with-qtdbus], [enable DBus support (default=auto)])],
    [use_dbus="$withval"],
    [use_dbus=auto])

  AC_SUBST(QT_TRANSLATION_DIR, [$qt_translation_path])
])

# Configure Qt libraries and tools
AC_DEFUN([BITCOIN_QT_CONFIGURE], [
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])
  use_pkgconfig="$1"
  auto_priority_version="$2"

  if test "x$use_pkgconfig" = "x"; then
    use_pkgconfig=yes
  fi
  if test "x$auto_priority_version" = "x"; then
    auto_priority_version=qt6
  fi

  if test "x$use_pkgconfig" = "xyes"; then
    BITCOIN_QT_CHECK([_BITCOIN_QT_FIND_LIBS_WITH_PKGCONFIG([$auto_priority_version])])
  else
    BITCOIN_QT_CHECK([_BITCOIN_QT_FIND_LIBS_WITHOUT_PKGCONFIG])
  fi

  BITCOIN_QT_CHECK([
    TEMP_CPPFLAGS="$CPPFLAGS"
    TEMP_CXXFLAGS="$CXXFLAGS"
    CPPFLAGS="$QT_INCLUDES $CPPFLAGS"
    CXXFLAGS="$PIC_FLAGS $CXXFLAGS"

    if test "x$bitcoin_qt_got_major_vers" != "x4"; then
      _BITCOIN_QT_IS_STATIC
      if test "x$bitcoin_cv_static_qt" = "xyes"; then
        _BITCOIN_QT_FIND_STATIC_PLUGINS
        AC_DEFINE([QT_STATICPLUGIN], [1], [Define if Qt plugins are static])
        if test "x$bitcoin_qt_got_major_vers" = "x5"; then
          AC_CACHE_CHECK([for Qt < 5.4], [bitcoin_cv_need_acc_widget], [
            AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <QtCore>]], [[
              #if QT_VERSION >= 0x050400
              #error Qt 5.4 or newer
              #endif]])],
              [bitcoin_cv_need_acc_widget=yes],
              [bitcoin_cv_need_acc_widget=no])
          ])
          if test "x$bitcoin_cv_need_acc_widget" = "xyes"; then
            _BITCOIN_QT_CHECK_STATIC_PLUGINS([Q_IMPORT_PLUGIN(AccessibleFactory)], [-lqtaccessiblewidgets])
          fi
        fi
        case $TARGET_OS in
          windows)
            _BITCOIN_QT_CHECK_STATIC_PLUGINS([Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)], [-lqwindows])
            AC_DEFINE([QT_QPA_PLATFORM_WINDOWS], [1], [Define if Qt platform is Windows])
            ;;
          linux)
            _BITCOIN_QT_CHECK_STATIC_PLUGINS([Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)], [-lqxcb -lxcb-static])
            AC_DEFINE([QT_QPA_PLATFORM_XCB], [1], [Define if Qt platform is XCB])
            ;;
          darwin)
            AX_CHECK_LINK_FLAG([[-framework IOKit]], [QT_LIBS="$QT_LIBS -framework IOKit"], [AC_MSG_ERROR([IOKit framework not found])])
            _BITCOIN_QT_CHECK_STATIC_PLUGINS([Q_IMPORT_PLUGIN(QCocoaIntegrationPlugin)], [-lqcocoa])
            AC_DEFINE([QT_QPA_PLATFORM_COCOA], [1], [Define if Qt platform is Cocoa])
            ;;
        esac
      fi
    else
      if test "x$TARGET_OS" = "xwindows"; then
        AC_DEFINE([QT_STATICPLUGIN], [1], [Define if Qt plugins are static])
        _BITCOIN_QT_CHECK_STATIC_PLUGINS([
          Q_IMPORT_PLUGIN(qcncodecs)
          Q_IMPORT_PLUGIN(qjpcodecs)
          Q_IMPORT_PLUGIN(qtwcodecs)
          Q_IMPORT_PLUGIN(qkrcodecs)
          Q_IMPORT_PLUGIN(AccessibleFactory)],
          [-lqcncodecs -lqjpcodecs -lqtwcodecs -lqkrcodecs -lqtaccessiblewidgets])
      fi
    fi

    CPPFLAGS="$TEMP_CPPFLAGS"
    CXXFLAGS="$TEMP_CXXFLAGS"
  ])

  if test "x$use_pkgconfig" = "xyes" && test -z "$qt_bin_path"; then
    case $bitcoin_qt_got_major_vers in
      5) qt_bin_path="`$PKG_CONFIG --variable=host_bins Qt5Core 2>/dev/null`" ;;
      6) qt_bin_path="`$PKG_CONFIG --variable=host_bins Qt6Core 2>/dev/null`" ;;
    esac
  fi

  BITCOIN_QT_CHECK([
    if test "x$use_hardening" != "xno"; then
      AC_MSG_CHECKING([whether -fPIE can be used with Qt])
      TEMP_CPPFLAGS="$CPPFLAGS"
      TEMP_CXXFLAGS="$CXXFLAGS"
      CPPFLAGS="$QT_INCLUDES $CPPFLAGS"
      CXXFLAGS="$PIE_FLAGS $CXXFLAGS"
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <QtCore/qconfig.h>]], [[
        #if defined(QT_REDUCE_RELOCATIONS)
        #error PIE not supported
        #endif]])],
        [AC_MSG_RESULT([yes]); QT_PIE_FLAGS="$PIE_FLAGS"],
        [AC_MSG_RESULT([no]); QT_PIE_FLAGS="$PIC_FLAGS"])
      CPPFLAGS="$TEMP_CPPFLAGS"
      CXXFLAGS="$TEMP_CXXFLAGS"
    else
      QT_PIE_FLAGS="$PIC_FLAGS"
    fi
  ])

  BITCOIN_QT_PATH_PROGS([MOC], [moc-qt${bitcoin_qt_got_major_vers} moc${bitcoin_qt_got_major_vers} moc], [$qt_bin_path])
  BITCOIN_QT_PATH_PROGS([UIC], [uic-qt${bitcoin_qt_got_major_vers} uic${bitcoin_qt_got_major_vers} uic], [$qt_bin_path])
  BITCOIN_QT_PATH_PROGS([RCC], [rcc-qt${bitcoin_qt_got_major_vers} rcc${bitcoin_qt_got_major_vers} rcc], [$qt_bin_path])
  BITCOIN_QT_PATH_PROGS([LRELEASE], [lrelease-qt${bitcoin_qt_got_major_vers} lrelease${bitcoin_qt_got_major_vers} lrelease], [$qt_bin_path])
  BITCOIN_QT_PATH_PROGS([LUPDATE], [lupdate-qt${bitcoin_qt_got_major_vers} lupdate${bitcoin_qt_got_major_vers} lupdate], [$qt_bin_path], [yes])

  MOC_DEFS="-DHAVE_CONFIG_H -I$(srcdir)"
  case $host in
    *darwin*)
      BITCOIN_QT_CHECK([
        MOC_DEFS="$MOC_DEFS -DQ_OS_MAC"
        base_frameworks="-framework Foundation -framework ApplicationServices -framework AppKit"
        AX_CHECK_LINK_FLAG([[$base_frameworks]], [QT_LIBS="$QT_LIBS $base_frameworks"], [AC_MSG_ERROR([Base macOS frameworks not found])])
      ])
      ;;
    *mingw*)
      BITCOIN_QT_CHECK([
        AX_CHECK_LINK_FLAG([[-mwindows]], [QT_LDFLAGS="$QT_LDFLAGS -mwindows"], [AC_MSG_WARN([-mwindows not supported])])
      ])
      ;;
  esac

  AC_MSG_CHECKING([whether to build ]AC_PACKAGE_NAME[ GUI])
  BITCOIN_QT_CHECK([
    bitcoin_enable_qt=yes
    bitcoin_enable_qt_test="$have_qt_test"
    bitcoin_enable_qt_dbus=no
    if test "x$use_dbus" != "xno" && test "x$have_qt_dbus" = "xyes"; then
      bitcoin_enable_qt_dbus=yes
    fi
    if test "x$use_dbus" = "xyes" && test "x$have_qt_dbus" = "xno"; then
      BITCOIN_QT_FAIL([QtDBus required but not found])
    fi
    if test "x$LUPDATE" = "x"; then
      AC_MSG_WARN([lupdate not found; translations cannot be updated])
    fi
    AC_MSG_RESULT([yes (Qt${bitcoin_qt_got_major_vers})])
  ], [
    bitcoin_enable_qt=no
    AC_MSG_RESULT([no])
  ])

  AC_SUBST(QT_PIE_FLAGS)
  AC_SUBST(QT_INCLUDES)
  AC_SUBST(QT_LIBS)
  AC_SUBST(QT_LDFLAGS)
  AC_SUBST(QT_DBUS_INCLUDES)
  AC_SUBST(QT_DBUS_LIBS)
  AC_SUBST(QT_TEST_INCLUDES)
  AC_SUBST(QT_TEST_LIBS)
  AC_SUBST(QT_SELECT, [qt${bitcoin_qt_got_major_vers}])
  AC_SUBST(MOC_DEFS)
])

# Internal: Check if Qt is Qt5 or later
AC_DEFUN([_BITCOIN_QT_CHECK_QT5], [
  AC_CACHE_CHECK([for Qt 5+], [bitcoin_cv_qt5], [
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <QtCore>]], [[
      #if QT_VERSION < 0x050000
      #error Qt < 5.0
      #endif]])],
      [bitcoin_cv_qt5=yes],
      [bitcoin_cv_qt5=no])
  ])
])

# Internal: Check if Qt is static
AC_DEFUN([_BITCOIN_QT_IS_STATIC], [
  AC_CACHE_CHECK([for static Qt], [bitcoin_cv_static_qt], [
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <QtCore>]], [[
      #if defined(QT_STATIC)
      return 0;
      #else
      #error Qt not static
      #endif]])],
      [bitcoin_cv_static_qt=yes],
      [bitcoin_cv_static_qt=no])
  ])
])

# Internal: Check static Qt plugin linking
AC_DEFUN([_BITCOIN_QT_CHECK_STATIC_PLUGINS], [
  AC_MSG_CHECKING([for static Qt plugins: $2])
  TEMP_LIBS="$LIBS"
  LIBS="$2 $QT_LIBS $LIBS"
  AC_LINK_IFELSE([AC_LANG_PROGRAM([[
    #define QT_STATICPLUGIN
    #include <QtPlugin>
    $1]], [[return 0;]])],
    [AC_MSG_RESULT([yes]); QT_LIBS="$2 $QT_LIBS"],
    [AC_MSG_RESULT([no]); BITCOIN_QT_FAIL([Could not link static plugins: $2])])
  LIBS="$TEMP_LIBS"
])

# Internal: Find static Qt plugins
AC_DEFUN([_BITCOIN_QT_FIND_STATIC_PLUGINS], [
  case $bitcoin_qt_got_major_vers in
    5|6)
      if test -n "$qt_plugin_path"; then
        QT_LIBS="$QT_LIBS -L$qt_plugin_path/platforms"
        if test -d "$qt_plugin_path/accessible"; then
          QT_LIBS="$QT_LIBS -L$qt_plugin_path/accessible"
        fi
      fi
      m4_ifdef([PKG_CHECK_MODULES], [
        if test "x$use_pkgconfig" = "xyes"; then
          PKG_CHECK_MODULES([QTPLATFORM], [Qt${bitcoin_qt_got_major_vers}Gui], [QT_LIBS="$QTPLATFORM_LIBS $QT_LIBS"], [])
          case $TARGET_OS in
            linux)
              PKG_CHECK_MODULES([X11XCB], [x11-xcb], [QT_LIBS="$X11XCB_LIBS $QT_LIBS"], [])
              PKG_CHECK_MODULES([QTXCBQPA], [Qt${bitcoin_qt_got_major_vers}XcbQpa], [QT_LIBS="$QTXCBQPA_LIBS $QT_LIBS"], [])
              ;;
            darwin)
              PKG_CHECK_MODULES([QTPRINT], [Qt${bitcoin_qt_got_major_vers}PrintSupport], [QT_LIBS="$QTPRINT_LIBS $QT_LIBS"], [])
              ;;
          esac
        else
          QT_LIBS="-lQt${bitcoin_qt_got_major_vers}PlatformSupport $QT_LIBS"
        fi
      ])
      ;;
    4)
      if test -n "$qt_plugin_path"; then
        QT_LIBS="$QT_LIBS -L$qt_plugin_path/accessible -L$qt_plugin_path/codecs"
      fi
      ;;
  esac
])

# Internal: Find Qt with pkg-config
AC_DEFUN([_BITCOIN_QT_FIND_LIBS_WITH_PKGCONFIG], [
  m4_ifdef([PKG_CHECK_MODULES], [
    auto_priority_version="$1"
    case $bitcoin_qt_want_version in
      qt6|auto)
        if test "x$bitcoin_qt_want_version" = "xqt6" || test "x$auto_priority_version" = "xqt6"; then
          PKG_CHECK_MODULES([QT], [Qt6Core Qt6Gui Qt6Network Qt6Widgets], [
            QT_INCLUDES="$QT_CFLAGS"
            QT_LIBS="$QT_LIBS"
            have_qt=yes
            QT_LIB_PREFIX=Qt6
            bitcoin_qt_got_major_vers=6
          ], [have_qt=no])
        fi
        if test "x$have_qt" != "xyes" && test "x$bitcoin_qt_want_version" = "xauto"; then
          PKG_CHECK_MODULES([QT], [Qt5Core Qt5Gui Qt5Network Qt5Widgets], [
            QT_INCLUDES="$QT_CFLAGS"
            QT_LIBS="$QT_LIBS"
            have_qt=yes
            QT_LIB_PREFIX=Qt5
            bitcoin_qt_got_major_vers=5
          ], [have_qt=no])
        fi
        ;;
      qt5)
        PKG_CHECK_MODULES([QT], [Qt5Core Qt5Gui Qt5Network Qt5Widgets], [
          QT_INCLUDES="$QT_CFLAGS"
          QT_LIBS="$QT_LIBS"
          have_qt=yes
          QT_LIB_PREFIX=Qt5
          bitcoin_qt_got_major_vers=5
        ], [BITCOIN_QT_FAIL([Qt5 not found])])
        ;;
      qt4)
        PKG_CHECK_MODULES([QT], [QtCore QtGui QtNetwork], [
          QT_INCLUDES="$QT_CFLAGS"
          QT_LIBS="$QT_LIBS"
          have_qt=yes
          QT_LIB_PREFIX=Qt
          bitcoin_qt_got_major_vers=4
        ], [BITCOIN_QT_FAIL([Qt4 not found])])
        ;;
      *)
        BITCOIN_QT_FAIL([Invalid --with-gui value: $bitcoin_qt_want_version])
        ;;
    esac

    if test "x$have_qt" != "xyes" && test "x$bitcoin_qt_want_version" = "xauto"; then
      PKG_CHECK_MODULES([QT], [QtCore QtGui QtNetwork], [
        QT_INCLUDES="$QT_CFLAGS"
        QT_LIBS="$QT_LIBS"
        have_qt=yes
        QT_LIB_PREFIX=Qt
        bitcoin_qt_got_major_vers=4
      ], [BITCOIN_QT_FAIL([No Qt version found])])
    fi

    BITCOIN_QT_CHECK([
      PKG_CHECK_MODULES([QT_TEST], [${QT_LIB_PREFIX}Test], [QT_TEST_INCLUDES="$QT_TEST_CFLAGS"; have_qt_test=yes], [have_qt_test=no])
      if test "x$use_dbus" != "xno"; then
        PKG_CHECK_MODULES([QT_DBUS], [${QT_LIB_PREFIX}DBus], [QT_DBUS_INCLUDES="$QT_DBUS_CFLAGS"; have_qt_dbus=yes], [have_qt_dbus=no])
      fi
    ])
  ])
])

# Internal: Find Qt without pkg-config
AC_DEFUN([_BITCOIN_QT_FIND_LIBS_WITHOUT_PKGCONFIG], [
  TEMP_CPPFLAGS="$CPPFLAGS"
  TEMP_CXXFLAGS="$CXXFLAGS"
  TEMP_LIBS="$LIBS"
  CXXFLAGS="$PIC_FLAGS $CXXFLAGS"

  BITCOIN_QT_CHECK([
    if test -n "$qt_include_path"; then
      QT_INCLUDES="-I$qt_include_path -I$qt_include_path/QtCore -I$qt_include_path/QtGui -I$qt_include_path/QtWidgets -I$qt_include_path/QtNetwork -I$qt_include_path/QtTest -I$qt_include_path/QtDBus"
      CPPFLAGS="$QT_INCLUDES $CPPFLAGS"
    fi
    AC_CHECK_HEADER([QtPlugin], [], [BITCOIN_QT_FAIL([QtCore headers missing])])
    AC_CHECK_HEADER([QApplication], [], [BITCOIN_QT_FAIL([QtGui headers missing])])
    AC_CHECK_HEADER([QLocalSocket], [], [BITCOIN_QT_FAIL([QtNetwork headers missing])])

    if test "x$bitcoin_qt_want_version" = "xauto"; then
      _BITCOIN_QT_CHECK_QT5
    fi
    case $bitcoin_qt_want_version in
      qt6|auto)
        if test "x$bitcoin_cv_qt5" = "xyes"; then
          QT_LIB_PREFIX=Qt6
          bitcoin_qt_got_major_vers=6
        elif test "x$bitcoin_qt_want_version" != "xauto"; then
          BITCOIN_QT_FAIL([Qt6 not found])
        else
          QT_LIB_PREFIX=Qt5
          bitcoin_qt_got_major_vers=5
        fi
        ;;
      qt5)
        if test "x$bitcoin_cv_qt5" = "xyes"; then
          QT_LIB_PREFIX=Qt5
          bitcoin_qt_got_major_vers=5
        else
          BITCOIN_QT_FAIL([Qt5 not found])
        fi
        ;;
      qt4)
        QT_LIB_PREFIX=Qt
        bitcoin_qt_got_major_vers=4
        ;;
    esac

    LIBS=""
    if test -n "$qt_lib_path"; then
      LIBS="-L$qt_lib_path"
    fi
    if test "x$TARGET_OS" = "xwindows"; then
      AC_CHECK_LIB([imm32], [main], [], [BITCOIN_QT_FAIL([libimm32 not found])])
    fi
    AC_CHECK_LIB([z], [main], [], [AC_MSG_WARN([zlib not found; assuming Qt has it built-in])])
    AC_CHECK_LIB([png], [main], [], [AC_MSG_WARN([libpng not found; assuming Qt has it built-in])])
    AC_CHECK_LIB([jpeg], [main], [], [AC_MSG_WARN([libjpeg not found; assuming Qt has it built-in])])
    AC_SEARCH_LIBS([pcre16_exec], [qtpcre pcre16], [], [AC_MSG_WARN([libpcre16 not found; assuming Qt has it built-in])])
    AC_SEARCH_LIBS([hb_ot_tags_from_script], [qtharfbuzzng harfbuzz], [], [AC_MSG_WARN([libharfbuzz not found; assuming Qt has it built-in or disabled])])

    AC_CHECK_LIB([${QT_LIB_PREFIX}Core], [main], [], [BITCOIN_QT_FAIL([lib${QT_LIB_PREFIX}Core not found])])
    AC_CHECK_LIB([${QT_LIB_PREFIX}Gui], [main], [], [BITCOIN_QT_FAIL([lib${QT_LIB_PREFIX}Gui not found])])
    AC_CHECK_LIB([${QT_LIB_PREFIX}Network], [main], [], [BITCOIN_QT_FAIL([lib${QT_LIB_PREFIX}Network not found])])
    if test "x$bitcoin_qt_got_major_vers" != "x4"; then
      AC_CHECK_LIB([${QT_LIB_PREFIX}Widgets], [main], [], [BITCOIN_QT_FAIL([lib${QT_LIB_PREFIX}Widgets not found])])
    fi
    QT_LIBS="$LIBS"

    LIBS=""
    if test -n "$qt_lib_path"; then
      LIBS="-L$qt_lib_path"
    fi
    AC_CHECK_LIB([${QT_LIB_PREFIX}Test], [main], [QT_TEST_LIBS="$LIBS"; have_qt_test=yes], [have_qt_test=no])
    AC_CHECK_HEADER([QTest], [], [have_qt_test=no])
    if test "x$use_dbus" != "xno"; then
      AC_CHECK_LIB([${QT_LIB_PREFIX}DBus], [main], [QT_DBUS_LIBS="$LIBS"; have_qt_dbus=yes], [have_qt_dbus=no])
      AC_CHECK_HEADER([QtDBus], [], [have_qt_dbus=no])
    fi
  ])

  CPPFLAGS="$TEMP_CPPFLAGS"
  CXXFLAGS="$TEMP_CXXFLAGS"
  LIBS="$TEMP_LIBS"
])
