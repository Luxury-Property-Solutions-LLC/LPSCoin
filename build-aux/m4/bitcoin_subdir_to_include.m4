# SYNOPSIS
#
#   BITCOIN_SUBDIR_TO_INCLUDE([CPPFLAGS-VARIABLE-NAME], [SUBDIRECTORY-NAME], [HEADER-FILE])
#
# DESCRIPTION
#
#   Constructs an include path for a header file within a subdirectory and
#   appends it to the specified CPPFLAGS variable. If SUBDIRECTORY-NAME is
#   empty, no action is taken. The subdirectory should typically end with a
#   path separator (e.g., '/'), but this is not strictly required.
#
#   Inputs:
#     $1: CPPFLAGS variable to modify (e.g., BDB_CPPFLAGS)
#     $2: Subdirectory containing the header (e.g., db4.8/)
#     $3: Header file name without path or extension (e.g., db_cxx)
#
#   Output:
#     Updates $1 with -I<full_path> if the header is found, otherwise warns.

AC_DEFUN([BITCOIN_SUBDIR_TO_INCLUDE], [
  AC_REQUIRE([AC_PROG_CXXCPP])
  if test "x$2" = "x"; then
    AC_MSG_RESULT([default include path for $3.h])
  else
    AC_MSG_CHECKING([for $3.h in $2])
    # Normalize subdirectory (ensure it ends with /)
    subdir=$(echo "$2" | sed 's|/*$|/|')
    # Construct test include directive
    echo "#include <${subdir}$3.h>" > conftest.cpp
    # Use CXXCPP to verify the header exists
    if ${CXXCPP} ${CPPFLAGS} conftest.cpp >/dev/null 2>&1; then
      # Extract the directory path containing the header
      incl_path=$(cd "${subdir%/*}" && pwd 2>/dev/null || echo "$subdir")
      if test -n "$incl_path"; then
        eval "$1=\"\$$1 -I${incl_path}\""
        AC_MSG_RESULT([$incl_path])
      else
        AC_MSG_RESULT([found but path unresolved])
        AC_MSG_WARN([Could not determine absolute path for $2; using relative path])
        eval "$1=\"\$$1 -I${subdir}\""
      fi
    else
      AC_MSG_RESULT([not found])
      AC_MSG_WARN([Header $3.h not found in $2; include path unchanged])
    fi
    rm -f conftest.cpp
  fi
])
