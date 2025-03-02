# Developer Tools for LPSCoin
This directory contains tools for developers working on the LPSCoin repository.
## check-doc.py
Check if all command-line arguments for `lpscoinsd` and `lpscoins-qt` are documented. The return value indicates the number of undocumented arguments.
## github-merge.py
A script to automate secure merging of pull requests with GPG signing.
Example:./github-merge.py 3077

Merges pull request #3077 from the `Luxury-Property-Solutions-LLC/LPSCoin` repository.
What it does:
- Fetches the master branch and the pull request.
- Constructs a local merge commit.
- Displays the resulting diff.
- Prompts to verify the source tree (e.g., run `make check`).
- Asks to GPG-sign the merge commit.
- Asks to push the merge upstream.
This avoids race conditions (e.g., pull request updates during review) and ensures source integrity with GPG signatures.
### Setup
Configure for LPSCoin:
./github-merge.py 3077
Merges pull request #3077 from the `Luxury-Property-Solutions-LLC/LPSCoin` repository.
What it does:
- Fetches the master branch and the pull request.
- Constructs a local merge commit.
- Displays the resulting diff.
- Prompts to verify the source tree (e.g., run `make check`).
- Asks to GPG-sign the merge commit.
- Asks to push the merge upstream.
This avoids race conditions (e.g., pull request updates during review) and ensures source integrity with GPG signatures.
### Setup
Configure for LPSCoin:
git config githubmerge.repository Luxury-Property-Solutions-LLC/LPSCoin
git config githubmerge.testcmd "make -j4 check"  # Adjust for your testing needs
git config --global user.signingkey <YOUR_GPG_KEY_ID>  # For GPG signing
## optimize-pngs.py
Optimizes PNG files in the LPSCoin repository using `pngcrush`. Requires `pngcrush` installed.
Example:
## optimize-pngs.py
Optimizes PNG files in the LPSCoin repository using `pngcrush`. Requires `pngcrush` installed.
Example:
./optimize-pngs.py
## fix-copyright-headers.py
Updates copyright headers in `.cpp` and `.h` files to include the current year for files modified in that year. Run from `src/`.
Example (for 2025):
// Copyright (c) 2009-2024 The LPSCoin Developers
becomes:

// Copyright (c) 2009-2025 The LPSCoin Developers

Usage:
cd src && ../contrib/devtools/fix-copyright-headers.py
## symbol-check.py
Checks that Linux executables from a Gitian build only use allowed `gcc`, `glibc`, and `libstdc++` version symbols, ensuring compatibility with minimum supported distributions.
Example after a Gitian build:

find ../gitian-builder/build -type f -executable | xargs python3 contrib/devtools/symbol-check.py

- Returns 0 with no output if only supported symbols are used.
- Returns 1 with a list of unsupported symbols if detected (e.g., `memcpy` from `GLIBC_2.14`).
## update-translations.py
Updates translations from Transifex, processes them into a committable format, and adds missing translations to the build system. Run from the repository root.
Usage:

python3 contrib/devtools/update-translations.py

See `doc/translation-process.md` for details.

