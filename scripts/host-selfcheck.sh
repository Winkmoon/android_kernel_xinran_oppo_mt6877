#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# [XINRAN] Required host tools self-check.
#
# A few helper binaries in this tree (tools/build/cpio,
# scripts/dtc/ufdt_apply_overlay) are x86-64 prebuilts taken from the Android
# tree.  They are deliberately not used here: the build always relies on the
# tools provided by the host system, so that it works on any architecture.
#
# This script is run from the top-level Makefile before anything is built, so a
# missing tool is reported once, early, with instructions - instead of failing
# later somewhere deep in the tree or, worse, being mistaken for a warning.
#
# On failure the output contains the token HOST_TOOLCHECK_FAILED and the exit
# status is non-zero; the Makefile turns that into a hard $(error).

set -u

# Host tools this build requires from the system.
REQUIRED="cpio"

missing=""
for t in $REQUIRED; do
	if ! command -v "$t" >/dev/null 2>&1; then
		missing="$missing $t"
	fi
done

if [ -n "$missing" ]; then
	# Human-readable details go to stderr so that make shows them as-is;
	# the marker token goes to stdout so the Makefile can detect the failure.
	cat >&2 <<EOF

********************************************************************************
***  ERROR: required host tool(s) missing  ***
********************************************************************************

  Host architecture : $(uname -m 2>/dev/null || echo unknown)
  Missing tool(s)   :$missing

  This build needs the following tools from the host system.  Install them and
  build again, for example:

    Debian/Ubuntu :  sudo apt-get install$missing
    Fedora/RHEL   :  sudo dnf install$missing
    Arch Linux    :  sudo pacman -S$missing
    openSUSE      :  sudo zypper install$missing
    Alpine        :  sudo apk add$missing

  (Set XINRAN_SKIP_HOSTCHECK=1 to bypass this check.)

********************************************************************************

EOF
	echo HOST_TOOLCHECK_FAILED
	exit 1
fi

exit 0
