# Depends Build System

## Usage

To build dependencies for the current architecture and OS:

```bash
make
To build for a specific architecture/OS:
make HOST=host-platform-triplet
For example, to build for 64-bit Windows with 4 parallel jobs:
make HOST=x86_64-w64-mingw32 -j4
A prefix directory will be generated, suitable for use with LPSCoin's configure script. In the above example, a directory named x86_64-w64-mingw32 will be created. To use it with LPSCoin:
./configure --prefix=`pwd`/depends/x86_64-w64-mingw32
./configure --prefix=`pwd`/depends/x86_64-w64-mingw32

Common Host Platform Triplets
Here are some common triplets for cross-compilation:

i686-w64-mingw32 - Windows 32-bit
x86_64-w64-mingw32 - Windows 64-bit
x86_64-apple-darwin20 - macOS (x86_64, adjust version for your SDK)
arm64-apple-darwin20 - macOS (ARM64, adjust version for your SDK)
arm-linux-gnueabihf - Linux ARM 32-bit
aarch64-linux-gnu - Linux ARM 64-bit
Note: Triplets depend on your toolchain; run ./config.sub with a triplet to canonicalize it (e.g., ./config.sub x86_64-apple-darwin).

No additional options are needed; paths are automatically configured.

Dependency Options
The following can be set when running make (e.g., make FOO=bar):

SOURCES_PATH: Directory where downloaded sources are stored (default: depends/sources).
BASE_CACHE: Directory where built packages are cached (default: depends/built).
SDK_PATH: Path to SDKs (used for macOS builds, default: depends/SDKs).
FALLBACK_DOWNLOAD_PATH: Fallback URL for source downloads if primary fails (default: https://bitcoincore.org/depends-sources).
NO_QT: Set to 1 to skip Qt and its dependencies.
NO_WALLET: Set to 1 to skip wallet-related libraries (passes --disable-wallet to configure).
NO_UPNP: Set to 1 to skip UPnP-related packages.
DEBUG: Set to 1 to disable optimizations and enable runtime checks.
HOST_ID_SALT: Optional salt for host package IDs (affects caching, default: salt).
BUILD_ID_SALT: Optional salt for build package IDs (affects caching, default: salt).
V: Set to 1 for verbose output (e.g., make V=1).
If packages are skipped (e.g., make NO_WALLET=1), appropriate options are passed to LPSCoin’s configure script (e.g., --disable-wallet).

Additional Targets
download: Fetch all sources without building:
make download
download-osx: Fetch sources for macOS builds:
make download-osx
download-win: Fetch sources for Windows builds:
make download-win
download-linux: Fetch sources for Linux builds:
make download-linux
Note: Combine targets as needed (e.g., make download-osx download-win).

Cleaning Up
To clean the build directory:
rm -rf depends/work/

Other Documentation
description.md: Overview of the depends system.
packages.md: Guide for adding new packages.
