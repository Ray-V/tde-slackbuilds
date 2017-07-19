#!/bin/sh
# Copyright 2015-2017  tde-slackbuilds project on GitHub
# All rights reserved.
#
#   Permission to use, copy, modify, and distribute this software for
#   any purpose with or without fee is hereby granted, provided that
#   the above copyright notice and this permission notice appear in all
#   copies.
#
#   THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
#   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#   USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#   OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.

getsource_fn ()
{
#!/bin/sh
# Generated by Alien's SlackBuild Toolkit: http://slackware.com/~alien/AST
# Copyright 2009, 2010, 2011, 2012, 2013, 2014, 2015  Eric Hameleers, Eindhoven, Netherlands
# Copyright 2015-2017  Thorn Inurcide USA
# Copyright 2015-2017  tde-slackbuilds project on GitHub
# All rights reserved.
#
#   Permission to use, copy, modify, and distribute this software for
#   any purpose with or without fee is hereby granted, provided that
#   the above copyright notice and this permission notice appear in all
#   copies.
#
#   THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
#   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#   USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#   OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.

# Where do we look for sources?
SRCDIR=$(cd $(dirname $0); pwd)
[[ ! -s $SRCDIR/../../src/${PRGNAM}-${VERSION}.${ARCHIVE_TYPE:-"tar.bz2"} ]] && rm $SRCDIR/../../src/${PRGNAM}-${VERSION}.${ARCHIVE_TYPE:-"tar.bz2"} 2>/dev/null
ln -sf $SRCDIR/../../src/${PRGNAM}-${VERSION}.${ARCHIVE_TYPE:-"tar.bz2"} $SRCDIR

# Place to build (TMP) package (PKG) and output (OUTPUT) the program:
TMP=${TMP:-/tmp/build}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

# remove any previous builds
[[ $KEEP_BUILD != "yes" ]] && rm -rf $TMP/{tmp,package}*

SOURCE=$SRCDIR/${PRGNAM}-${VERSION}.${ARCHIVE_TYPE:-"tar.bz2"}
# SRCURL for non-TDE archives, set in the SB, will override the Trinity default *tar.bz2 URL
SRCURL=${SRCURL:-"http://$TDE_MIRROR/releases/${VERSION}$TDEMIR_SUBDIR/${PRGNAM}-${VERSION}.tar.bz2"}

# Automatically determine the architecture we're building on:
  MARCH=$( uname -m )
# uname -m will give the wrong architecture if 32bit with 64bit kernel
    [[ $MARCH == "x86_64" ]] && ! [[ -d /lib64 ]] && MARCH="i586"
  if [ -z "$ARCH" ]; then
    case "$MARCH" in
      i?86)    export ARCH=i586 ;;
      armv7hl) export ARCH=$MARCH ;;
      armv6hl) export ARCH=$MARCH ;;
      arm*)    export ARCH=arm ;;
      # Unless $ARCH is already set, use uname -m for all other archs:
      *)       export ARCH=$MARCH ;;
    esac
  fi
  # Set CFLAGS/CXXFLAGS and LIBDIRSUFFIX:
  case "$ARCH" in
    i586)      SLKCFLAGS="-O2 -march=i586 -mtune=i686"
               SLKLDFLAGS="-L$INSTALL_TDE/lib$LIBDIRSUFFIX"
               ;;
    x86_64)    SLKCFLAGS="-O2 -fPIC"
               SLKLDFLAGS="-L$INSTALL_TDE/lib$LIBDIRSUFFIX -L/usr/lib64"
               ;;
    armv7hl)   SLKCFLAGS="-O2 -march=armv7-a -mfpu=vfpv3-d16"
               SLKLDFLAGS="-L$INSTALL_TDE/lib$LIBDIRSUFFIX"
               ;;
    armv6hl)   SLKCFLAGS="-O2 -march=armv6 -mfpu=vfp -mfloat-abi=hard"
               SLKLDFLAGS="-L$INSTALL_TDE/lib$LIBDIRSUFFIX"
               ;;
    *)         SLKCFLAGS=${SLKCFLAGS:-"O2"}
               SLKLDFLAGS=${SLKLDFLAGS:-""}; LIBDIRSUFFIX=${LIBDIRSUFFIX:-""}
               ;;
  esac

case "$ARCH" in
    arm*)    TARGET=$ARCH-slackware-linux-gnueabi ;;
    *)       TARGET=$ARCH-slackware-linux ;;
esac

# Exit the script on errors:
set -e
trap 'echo "$0 FAILED at line ${LINENO}" | tee $OUTPUT/error-${PRGNAM}.log' ERR
# Catch unitialized variables:
set -u
P1=${1:-1}

# Save old umask and set to 0022:
_UMASK_=$(umask)
umask 0022

# Create working directories:
mkdir -p $OUTPUT
mkdir -p $TMP/tmp-$PRGNAM
mkdir -p $PKG
rm -rf $PKG/*
rm -rf $TMP/tmp-$PRGNAM/*
rm -rf $OUTPUT/{checkout,configure,make,install,error,makepkg,patch}-$PRGNAM.log

# Source file availability:
if ! [ -f ${SOURCE} ]; then
  echo "Source '$(basename ${SOURCE})' not available yet..."
  # Check if the $SRCDIR is writable at all - if not, download to $OUTPUT
  [ -w "$SRCDIR" ] || SOURCE="$OUTPUT/$(basename $SOURCE)"
  if [ -f ${SOURCE} ]; then echo "Ah, found it!"; continue; fi
  if ! [ "x${SRCURL}" == "x" ]; then
    echo "Will download file to $(dirname $SOURCE)"
    wget -T 20 -O "${SOURCE}" "${SRCURL}" 
    if [ $? -ne 0 -o ! -s "${SOURCE}" ]; then
      echo "Downloading '$(basename ${SOURCE})' failed... aborting the build."
      mv -f "${SOURCE}" "${SOURCE}".FAIL
      ${EXIT_FAIL:-":"}
    fi
  else
    echo "File '$(basename ${SOURCE})' not available... aborting the build."
    ${EXIT_FAIL:-":"}
  fi
fi

if [ "$P1" == "--download" ]; then
  echo "Download complete."
  exit 0
fi
}

untar_fn ()
{
cd $TMP/tmp-$PRGNAM
tar -xf ${SOURCE}
[[ $TDEMIR_SUBDIR != misc ]] && cd ./$(echo $TDEMIR_SUBDIR | cut -d / -f 2) && cd ${PRGNAM} || cd ${PRGNAM}-${VERSION}
}

listdocs_fn ()
{
DOCDIR=$PWD # this is set for installdocs_fn
DOCS=$(for file in AUTHORS* rfc4791.pdf ChangeLog* COPYING* CreatingThemes FAQ* HOWTO INSTALL* KNOWNBUGS* LICEN?E* NEWS* *README{$,^[\.*\.txt],/}* ${RM_LIST:-} ${KEYS_LIST:-} TODO* *.lsm ^[README]*.txt PKG-INFO doc/licenses/* doc/FAQ.txt REMARKS ; do [[ -s $file ]] && ls -1 $file;done ) || true
}

chown_fn ()
{
chown -R root:root .
chmod -R u+w,go+r-w,a+rX-st .
}

ltoolupdate_fn ()
{
cp /$(grep -h ltmain.sh /var/log/packages/libtool*) admin/
cp /$(grep -h libtool.m4 /var/log/packages/libtool*) admin/libtool.m4.in
cp /$(grep -h missing /var/log/packages/libtool*) admin/

make -f admin/Makefile.common
}

cd_builddir_fn ()
{
mkdir -p build-${PRGNAM}
cd build-${PRGNAM}
}

make_fn ()
{
make ${NUMJOBS:-} || exit 1
make DESTDIR=$PKG install || exit 1
}

installdocs_fn ()
{
[[ $TDEMIR_SUBDIR == misc || $PRGNAM == libart-lgpl ]] && INSTALL_TDE=/usr
mkdir -p $PKG${INSTALL_TDE}/doc/$PRGNAM-$VERSION
(cd $DOCDIR;cp -a --parents ${DOCS:-} $PKG${INSTALL_TDE}/doc/$PRGNAM-$VERSION) || true
cat $SRCDIR/$(basename $0) > $PKG${INSTALL_TDE}/doc/$PRGNAM-$VERSION/$PRGNAM.SlackBuild
chown -R root:root $PKG${INSTALL_TDE}/doc/$PRGNAM-$VERSION
find $PKG${INSTALL_TDE}/doc -type f -exec chmod 644 {} \;
}

mangzip_fn ()
{
if [ -d $PKG/usr/man ]; then
  find $PKG/usr/man -type f -name "*.?" -exec gzip -9f {} \;
  for i in $(find $PKG/usr/man -type l -name "*.?") ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done
fi
}

strip_fn ()
{
find $PKG | xargs file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null || true
}

mkdir_install_fn ()
{
mkdir -p $PKG/install
}

makepkg_fn ()
{
cd $PKG
makepkg --linkadd y --chown n $OUTPUT/${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.${PKGTYPE:-txz} 
cd $OUTPUT
md5sum ${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.${PKGTYPE:-txz} > ${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.${PKGTYPE:-txz}.md5
cat $PKG/install/slack-desc | grep "^${PRGNAM}" | grep -v handy > $OUTPUT/${PRGNAM}-${VERSION}-${ARCH}-${BUILD}${TAG}.txt

# Restore the original umask:
umask ${_UMASK_}
}

libpng16_fn ()
{
(cd /usr/bin
ln -sf libpng16-config libpng-config )
(cd /usr/include
ln -sf libpng16/pngconf.h pngconf.h
ln -sf libpng16/png.h png.h )
(cd /usr/lib64/pkgconfig
ln -sf libpng16.pc libpng.pc )
(cd /usr/lib64
ln -sf libpng16.so libpng.so
ln -sf libpng16.la libpng.la )
}
