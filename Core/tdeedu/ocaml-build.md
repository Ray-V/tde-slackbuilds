Ocaml upstream have removed native compilation for 32-bit in ocaml v5.  
This fork restores that, so ***ocamlopt***, which is required for the equation solver build, will be built.  
See https://www.tunbury.org/2026/03/03/32bit-backends/ for more details.

Get sources

```bash
mkdir /ocaml-build
cd /ocaml-build

git clone -n -b arm32-multicore https://github.com/mtelvers/ocaml
wget https://github.com/Emmanuel-PLF/facile/archive/1.1.4/facile-1.1.4.tar.gz
wget -O Zarith-1.14.tar.gz https://github.com/ocaml/Zarith/archive/refs/tags/release-1.14.tar.gz
```

Set system architecture

```bash
[[ $(getconf LONG_BIT) == 64 ]] && { LIBDIRSUFFIX=64 && ARCH=x86_64 ;} || ARCH=i586
```

Ocaml build

```bash
cp -a ocaml ocaml-wkg

cd ocaml-wkg
git checkout # default is 'origin/arm32-multicore'

./configure --enable-debug-runtime=no --enable-ocamldebug=no --enable-ocamltest=no --enable-stdlib-manpages=no --enable-static=no --with-relative-libdir=../lib$LIBDIRSUFFIX/ocaml

make -j4 world.opt

DESTDIR=/ocaml-build/ocaml-pkg make install
OCAML_VERSION=$(grep -o OCAML_VERSION_STRING.*$ ./runtime/caml/version.h| grep -o 5.[0-9.]*)

cd ../ocaml-pkg
find usr/local/ | xargs file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null

makepkg -l y -c n ../ocaml-$OCAML_VERSION-$ARCH.txz

cd ..
installpkg --terse ocaml-$OCAML_VERSION-$ARCH.txz
```

Facile build as per ArchLinux PKGBUILD & ocaml5.patch

```bash
tar xf facile-1.1.4.tar.gz
cd facile-1.1.4/lib
sed -i 's|Pervasives|Stdlib|g' *

make

install -Dm644 facile.cmx facile.cmxa facile.cmi facile.cma facile.a \
-t ../../facile-pkg/usr/local/lib$LIBDIRSUFFIX/ocaml/facile

cd ../../facile-pkg
makepkg -l y -c n ../facile-1.1.4-$ARCH.txz

cd ..
installpkg --terse facile-1.1.4-$ARCH.txz
```

Zarith build

```bash
tar xf Zarith-1.14.tar.gz
cd Zarith-release-1.14/

./configure -installdir ../zarith-pkg/usr/local/lib$LIBDIRSUFFIX/ocaml

make

DESTDIR=../zarith-pkg make install

cd ../zarith-pkg
makepkg -l y -c n ../Zarith-1.14-$ARCH.txz

cd ..
installpkg --terse Zarith-1.14-$ARCH.txz
```

Now do tdeedu build with ocaml_solver

```bash
EQ_SOLVER=ON ./BUILD-TDE.sh
```
***ocaml, facile, and Zarith are build time requirements so can be removed after the tdeedu build.***
