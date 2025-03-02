#!/usr/bin/env python3

# This script generates a comma-separated list of language codes for Qt icons
# to include in binary LPSCoin distributions by comparing Qt and LPSCoin
# translation files.

import glob
import os
import re
import sys

if len(sys.argv) != 3:
    sys.exit(f"Usage: {sys.argv[0]} QTDIR/translations LPSCOINDIR/src/qt/locale")

qt_trans_dir = sys.argv[1]
lpscoin_locale_dir = sys.argv[2]

# Extract language codes from Qt translation files (e.g., qt_en.qm → en)
qt_langs = {re.search(r'qt_(.*)\.qm$', f).group(1) for f in glob.glob(os.path.join(qt_trans_dir, 'qt_*.qm'))}
# Extract language codes from LPSCoin translation files (e.g., lpscoin_en.qm → en)
lpscoin_langs = {re.search(r'lpscoin_(.*)\.qm$', f).group(1) for f in glob.glob(os.path.join(lpscoin_locale_dir, 'lpscoin_*.qm'))}

# Output common languages as a comma-separated list
print(",".join(sorted(qt_langs.intersection(lpscoin_langs))))
