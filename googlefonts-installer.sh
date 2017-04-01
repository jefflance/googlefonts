#!/bin/bash
#
# modified by Jeff LANCE <jeff.lance@mala.fr> because repo used in original
#   script written by Simon <simonjwiles@gmail.com> was archived by Google.
#   The Google Fonts code was moved to github. (17/11/15).
# written by Simon <simonjwiles@gmail.com>
# inspired by a script written by Michalis Georgiou <mechmg93@gmail.com>
#   and modified by Andrew http://www.webupd8.org <andrew@webupd8.org>,
#   described at
#   http://www.webupd8.org/2011/01/automatically-install-all-google-web.html
#
#  (but completely re-written)
#

OSTYPE=$(uname -s);
GITROOT="https://github.com/google/fonts.git";
FONTDIR="/usr/share/fonts/truetype/google-fonts";

set -e;

exists() { which "$1" &> /dev/null ; }

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (i.e. with sudo)!" 1>&2;
    exit 1;
fi

if ! exists git ; then
    echo "Git is required (hint: sudo apt-get install git)!" 1>&2;
    exit 1;
fi

case "$OSTYPE" in
    Linux)
        FONTDIR="/usr/share/fonts/truetype/google-fonts";
        ;;
    Darwin)
        FONTDIR="/Library/Fonts/google-fonts";
        ;;
    *)
        exit 0
        ;;
esac

mkdir -p "$FONTDIR";

TMPDIR=$(mktemp -d);
trap 'rm -rf "$TMPDIR"' EXIT INT QUIT TERM;

echo -n "Getting data from GoogleCode Repository... "
git clone $GITROOT $TMPDIR > /dev/null;
if [ $? != 0 ]; then
    echo "Couldn't get data from GoogleCode Repository!  Aborting!" 1>&2;
    exit 1;
fi
echo "done!"

echo -n "Installing fonts... "
find $TMPDIR/ -name '*.ttf' -exec install -m644 {} "$FONTDIR" \;
echo "done!"

if [ $OSTYPE == "Linux" ]; then
    echo "Updating font cache... "
    fc-cache -fvs "$FONTDIR";
fi

echo "All done!"
