# BitRPC

BitRPC is a Python-based utility for interacting with the LPSCoin daemon (`lpscoinsd`) using Remote Procedure Call (RPC) commands. It enables sending standard Bitcoin/LPSCoin commands programmatically, offering an alternative to command-line arguments.

## Features

- Send all LPSCoin RPC commands supported by `lpscoinsd`.
- Scriptable interface for automation and integration.
- Compatible with wallet-related operations.

## Installation

BitRPC requires Python 3 (recommended: 3.8+ as of March 2025). To use:

1. Ensure `lpscoinsd` is built and running with RPC enabled (default in `configure.ac` with `--with-daemon`).
2. Install dependencies:
   ```bash
   pip install requests
   Copy bitrpc.py from contrib/bitrpc/ to your working directory or add it to your PATH.
Usage
Run BitRPC from the command line:
python bitrpc.py <command> [arguments]

Examples
Get blockchain info:
python bitrpc.py getblockchaininfo

Unlock the wallet:
python bitrpc.py walletpassphrase "yourpassphrase" 60

Change wallet passphrase:
python bitrpc.py walletpassphrasechange "oldpassphrase" "newpassphrase"

Wallet Tools Replacement
BitRPC can replace standalone wallet scripts in contrib/:

walletunlock.py: Use python bitrpc.py walletpassphrase <passphrase> <timeout> instead.
walletchangepass.py: Use python bitrpc.py walletpassphrasechange <oldpassphrase> <newpassphrase> instead.
Configuration
Ensure your lpscoin.conf enables RPC:

rpcuser=youruser
rpcpassword=yourpassword
rpcport=8332  # Default; adjust if changed
server=1

Build Integration
BitRPC relies on lpscoinsd, built via the Autoconf system in the LPSCoin root directory. To enable:

Run ./configure with --with-daemon (default: yes).
Build with make.
For wallet support (required for walletpassphrase and walletpassphrasechange):

Use --enable-wallet (default: yes) to include Berkeley DB 4.8+ support.
See configure.ac and build-aux/m4/ for details on build options.

Troubleshooting
RPC Connection Errors: Verify lpscoinsd is running and the RPC credentials match lpscoin.conf.
Command Not Found: Check the LPSCoin RPC command list with python bitrpc.py help.
Contributing
Submit pull requests or issues to the LPSCoin GitHub repository. Ensure changes are compatible with Python 3.8+ and the latest lpscoinsd RPC interface.

