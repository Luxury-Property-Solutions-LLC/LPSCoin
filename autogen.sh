#!/bin/sh
# autogen.sh - Generate build configuration files for LPSCoin Core
# Run this script from the repository root to prepare for ./configure

set -e

# Resolve source directory robustly
srcdir="$(dirname "$0")"
if [ -n "$srcdir" ] && [ "$srcdir" != "." ]; then
  cd "$srcdir" || { echo "Error: Cannot change to directory $srcdir"; exit 1; }
fi

# Detect libtoolize (Linux: libtoolize, macOS: glibtoolize)
if [ -z "$LIBTOOLIZE" ]; then
  for tool in libtoolize glibtoolize; do
    if command -v "$tool" >/dev/null 2>&1; then
      LIBTOOLIZE="$tool"
      export LIBTOOLIZE
      break
    fi
  done
  if [ -z "$LIBTOOLIZE" ]; then
    echo "Error: Neither libtoolize nor glibtoolize found. Install libtool package."
    exit 1
  fi
fi

# Check autoreconf version (requires 2.60 or newer per configure.ac)
autoreconf_version=$(autoreconf --version | head -n1 | grep -o '[0-9]\.[0-9]\+' || echo "unknown")
if [ "$autoreconf_version" = "unknown" ] || [ "$(printf '%s\n' "2.60" "$autoreconf_version" | sort -V | head -n1)" != "2.60" ]; then
  echo "Warning: autoreconf version $autoreconf_version detected; 2.60 or newer recommended."
fi

# Run autoreconf with verbose output and conditional force
if [ -f configure ]; then
  echo "Existing configure found; running autoreconf without --force."
  autoreconf --install --warnings=all --verbose || { echo "Error: autoreconf failed"; exit 1; }
else
  echo "No configure found; running autoreconf with --force."
  autoreconf --install --force --warnings=all --verbose || { echo "Error: autoreconf failed"; exit 1; }
fi

echo "Build configuration files generated successfully. Run ./configure next."
