#!/bin/bash
# Copyright (c) 2016-2025 The LPSCoin Developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# What to do
sign=false
verify=false
build=false
setupenv=false

# Systems to build
linux=true
windows=true
macos=true

# Basic variables
SIGNER=
VERSION=
commit=false
url=https://github.com/Luxury-Property-Solutions-LLC/LPSCoin
proc=2
mem=2000
lxc=true
osslTarUrl=https://downloads.sourceforge.net/project/osslsigncode/osslsigncode/osslsigncode-2.1.tar.gz
osslPatchUrl=https://bitcoincore.org/cfields/osslsigncode-Backports-to-2.1.patch
scriptName=$(basename -- "$0")
signProg="gpg --detach-sign"
commitFiles=true

# Help Message
read -d '' usage <<- EOF
Usage: $scriptName [-c|u|v|b|s|B|o|h|j|m] signer version

Run this script from the directory containing the lpscoin, gitian-builder, gitian.sigs, and lpscoin-detached-sigs repositories.

Arguments:
signer          GPG signer to sign each build assert file
version         Version number, commit, or branch to build. Use -c for commits or branches

Options:
-c|--commit     Indicate that the version argument is a commit or branch
-u|--url        Specify the repository URL (default: $url)
-v|--verify     Verify the Gitian build
-b|--build      Perform a Gitian build
-s|--sign       Make signed binaries for Windows and macOS
-B|--buildsign  Build both signed and unsigned binaries
-o|--os         Specify OSes to build: 'l' for Linux, 'w' for Windows, 'x' for macOS (default: lwx)
-j              Number of processes to use (default: $proc)
-m              Memory to allocate in MiB (default: $mem)
--kvm           Use KVM instead of LXC
--setup         Set up the Gitian environment (uses KVM unless --lxc is specified; Debian/Ubuntu only)
--detach-sign   Create assert files for detached signing without committing
--no-commit     Do not commit to git
-h|--help       Print this help message
EOF

# Parse options and arguments
while :; do
    case $1 in
        -v|--verify) verify=true ;;
        -b|--build) build=true ;;
        -s|--sign) sign=true ;;
        -B|--buildsign) sign=true; build=true ;;
        -S|--signer)
            if [ -n "$2" ]; then SIGNER=$2; shift; else echo "Error: '--signer' requires a non-empty argument."; exit 1; fi ;;
        -o|--os)
            if [ -n "$2" ]; then
                linux=false; windows=false; macos=false
                [[ "$2" =~ "l" ]] && linux=true
                [[ "$2" =~ "w" ]] && windows=true
                [[ "$2" =~ "x" ]] && macos=true
                shift
            else echo "Error: '--os' requires an argument with 'l' (Linux), 'w' (Windows), or 'x' (macOS)"; exit 1; fi ;;
        -h|--help) echo "$usage"; exit 0 ;;
        -c|--commit) commit=true ;;
        -j) if [ -n "$2" ]; then proc=$2; shift; else echo "Error: '-j' requires an argument"; exit 1; fi ;;
        -m) if [ -n "$2" ]; then mem=$2; shift; else echo "Error: '-m' requires an argument"; exit 1; fi ;;
        -u) if [ -n "$2" ]; then url=$2; shift; else echo "Error: '-u' requires an argument"; exit 1; fi ;;
        --kvm) lxc=false ;;
        --detach-sign) signProg="true"; commitFiles=false ;;
        --no-commit) commitFiles=false ;;
        --setup) setupenv=true ;;
        *) break ;;
    esac
    shift
done

# Set up LXC
if [[ $lxc = true ]]; then
    export USE_LXC=1
    export LXC_BRIDGE=lxcbr0
    sudo ifconfig lxcbr0 up 10.0.2.2
fi

# Check for macOS SDK
if [[ ! -e "gitian-builder/inputs/MacOSX10.11.sdk.tar.gz" && $macos = true ]]; then
    echo "Cannot build for macOS, SDK does not exist. Will build for other OSes"
    macos=false
fi

# Get signer and version
SIGNER=${1:-}
shift
VERSION=${1:-}
COMMIT=$VERSION

# Validate inputs
if [[ -z "$SIGNER" ]]; then
    echo "$scriptName: Missing signer."
    echo "Try $scriptName --help for more information"
    exit 1
fi
if [[ -z "$VERSION" ]]; then
    echo "$scriptName: Missing version."
    echo "Try $scriptName --help for more information"
    exit 1
fi

# Add "v" prefix if not a commit
[[ $commit = false ]] && COMMIT="v${VERSION}"
echo "Building commit: $COMMIT"

# Setup build environment
if [[ $setupenv = true ]]; then
    sudo apt-get update
    sudo apt-get install -y ruby apache2 git apt-cacher-ng python3-pyvmomi qemu-kvm qemu-utils
    git clone https://github.com/Luxury-Property-Solutions-LLC/gitian.sigs.git
    git clone https://github.com/Luxury-Property-Solutions-LLC/lpscoin-detached-sigs.git
    git clone https://github.com/devrandom/gitian-builder.git
    pushd ./gitian-builder
    if [[ -n "$USE_LXC" ]]; then
        sudo apt-get install -y lxc
        bin/make-base-vm --suite focal --arch amd64 --lxc
    else
        bin/make-base-vm --suite focal --arch amd64
    fi
    popd
fi

# Set up build
pushd ./lpscoin
git fetch
git checkout ${COMMIT}
popd

# Build
if [[ $build = true ]]; then
    mkdir -p ./lpscoin-binaries/${VERSION}
    echo ""
    echo "Building Dependencies"
    echo ""
    pushd ./gitian-builder
    mkdir -p inputs
    wget -N -P inputs $osslPatchUrl
    wget -N -P inputs $osslTarUrl
    make -C ../lpscoin/depends download SOURCES_PATH=$(pwd)/cache/common

    # Linux
    if [[ $linux = true ]]; then
        echo ""
        echo "Compiling ${VERSION} Linux"
        echo ""
        ./bin/gbuild -j ${proc} -m ${mem} --commit lpscoin=${COMMIT} --url lpscoin=${url} ../lpscoin/contrib/gitian-descriptors/gitian-linux.yml
        ./bin/gsign -p "$signProg" --signer "$SIGNER" --release ${VERSION}-linux --destination ../gitian.sigs/ ../lpscoin/contrib/gitian-descriptors/gitian-linux.yml
        mv build/out/lpscoin-*.tar.gz build/out/src/lpscoin-*.tar.gz ../lpscoin-binaries/${VERSION}
    fi

    # Windows
    if [[ $windows = true ]]; then
        echo ""
        echo "Compiling ${VERSION} Windows"
        echo ""
        ./bin/gbuild -j ${proc} -m ${mem} --commit lpscoin=${COMMIT} --url lpscoin=${url} ../lpscoin/contrib/gitian-descriptors/gitian-win.yml
        ./bin/gsign -p "$signProg" --signer "$SIGNER" --release ${VERSION}-win-unsigned --destination ../gitian.sigs/ ../lpscoin/contrib/gitian-descriptors/gitian-win.yml
        mv build/out/lpscoin-*-win-unsigned.tar.gz inputs/lpscoin-win-unsigned.tar.gz
        mv build/out/lpscoin-*.zip build/out/lpscoin-*.exe ../lpscoin-binaries/${VERSION}
    fi

    # macOS
    if [[ $macos = true ]]; then
        echo ""
        echo "Compiling ${VERSION} macOS"
        echo ""
        ./bin/gbuild -j ${proc} -m ${mem} --commit lpscoin=${COMMIT} --url lpscoin=${url} ../lpscoin/contrib/gitian-descriptors/gitian-osx.yml
        ./bin/gsign -p "$signProg" --signer "$SIGNER" --release ${VERSION}-osx-unsigned --destination ../gitian.sigs/ ../lpscoin/contrib/gitian-descriptors/gitian-osx.yml
        mv build/out/lpscoin-*-osx-unsigned.tar.gz inputs/lpscoin-osx-unsigned.tar.gz
        mv build/out/lpscoin-*.tar.gz build/out/lpscoin-*.dmg ../lpscoin-binaries/${VERSION}
    fi
    popd

    if [[ $commitFiles = true ]]; then
        echo ""
        echo "Committing ${VERSION} Unsigned Sigs"
        echo ""
        pushd gitian.sigs
        git add ${VERSION}-linux/${SIGNER}
        git add ${VERSION}-win-unsigned/${SIGNER}
        git add ${VERSION}-osx-unsigned/${SIGNER}
        git commit -a -m "Add ${VERSION} unsigned sigs for ${SIGNER}"
        popd
    fi
fi

# Verify the build
if [[ $verify = true ]]; then
    pushd ./gitian-builder
    echo ""
    echo "Verifying v${VERSION} Linux"
    echo ""
    ./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-linux ../lpscoin/contrib/gitian-descriptors/gitian-linux.yml
    echo ""
    echo "Verifying v${VERSION} Windows"
    echo ""
    ./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-win-unsigned ../lpscoin/contrib/gitian-descriptors/gitian-win.yml
    echo ""
    echo "Verifying v${VERSION} macOS"
    echo ""
    ./bin/gverify -v -d ../gitian.sigs/ -r ${VERSION}-osx-unsigned ../lpscoin/contrib/gitian-descriptors/gitian-osx.yml
    popd
fi

# Sign binaries
if [[ $sign = true ]]; then
    pushd ./gitian-builder
    if [[ $windows = true ]]; then
        echo ""
        echo "Signing ${VERSION} Windows"
        echo ""
        ./bin/gbuild -i --commit signature=${COMMIT} ../lpscoin/contrib/gitian-descriptors/gitian-win-signer.yml
        ./bin/gsign -p "$signProg" --signer "$SIGNER" --release ${VERSION}-win-signed --destination ../gitian.sigs/ ../lpscoin/contrib/gitian-descriptors/gitian-win-signer.yml
        mv build/out/lpscoin-*win64-setup.exe ../lpscoin-binaries/${VERSION}
        mv build/out/lpscoin-*win32-setup.exe ../lpscoin-binaries/${VERSION}
    fi
    if [[ $macos = true ]]; then
        echo ""
        echo "Signing ${VERSION} macOS"
        echo ""
        ./bin/gbuild -i --commit signature=${COMMIT} ../lpscoin/contrib/gitian-descriptors/gitian-osx-signer.yml
        ./bin/gsign -p "$signProg" --signer "$SIGNER" --release ${VERSION}-osx-signed --destination ../gitian.sigs/ ../lpscoin/contrib/gitian-descriptors/gitian-osx-signer.yml
        mv build/out/lpscoin-osx-signed.dmg ../lpscoin-binaries/${VERSION}/lpscoin-${VERSION}-osx.dmg
    fi
    popd

    if [[ $commitFiles = true ]]; then
        echo ""
        echo "Committing ${VERSION} Signed Sigs"
        echo ""
        pushd gitian.sigs
        git add ${VERSION}-win-signed/${SIGNER}
        git add ${VERSION}-osx-signed/${SIGNER}
        git commit -a -m "Add ${VERSION} signed binary sigs for ${SIGNER}"
        popd
    fi
fi
