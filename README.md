[<img src="https://ray-v.github.io/TDE-aarch64-gui.png">](https://ray-v.github.io/TDE-aarch64-gui.png "TDE desktop")  
... a TDE desktop, cross compiled for aarch64, running on a RPi4.

---
***Build TDE [Trinity Desktop Environment]***  
.. for Slackware [x86_64/i586+/arm], and [Slarm64](https://slackware.uk/slarm64/) [aarch64].  
See [*Cross compiling for RPi3*](#xcompiling) for building for arm_hf and aarch64.

For a native build, run **./BUILD-TDE.sh** - a dialog based script with a series of screens for user input which will build the release version 14.1.5 or the development versions 14.1.x/14.2.0.

[<img src="https://ray-v.github.io/TDE-version.png">](https://ray-v.github.io/TDE-version.png "TDE version")  
... select TDE version

The Required packages will need to be installed as they are built, because they provide dependencies for other TDE packages.

Any package, or set of packages, can be selected in the 'TDE Packages Selection' screen.  
Information about dependencies for some packages has been added at the bottom of the dialog screen.

Only building the packages is a global option. It therefore can't be used where the build list includes packages which will need to be installed as dependencies for other packages in the build list [for example tdesdk needs tdepim to be installed].

14.1.5 source archives will be downloaded from a geoIP located mirror site, or the development sources 14.1.x/14.2.0 cloned or updated from trinitydesktop gitea.  
Downloading can be done pre-build [useful for an off-line build], or during the build.

If you're curious about what this might involve, [take a look at a sample build set up](https://ray-v.github.io/A_typical_TDE_SlackBuild.html).

---

***Command line options*** that can be used to set some build parameters:
* TDE_MIRROR= - override the trinitydesktop.org geoIP redirector to use https.  
   For example, *TDE_MIRROR=https://trinitydesktop.mirrorservice.org ./BUILD-TDE.sh*  
URLs for this and other locations are @ https://www.trinitydesktop.org/mirrorstatus.php
* BUILD= - sets the package build identifier, overriding the SlackBuild default of 1
* GCC_VIS=0 - override setting gcc visibility if it has been set ON in tdelibs
* FEAT= - test a pre-merge feature for development builds - see notes in get-source.sh
* build_regextester=[yp] - build the regex tester from the tqt example - see the tqt README
* mailmerge=n - build kword without mailmerge - see the koffice README and SlackBuild
* KP_BTN=n - build ksnapshot without the dedicated KolourPaint button - see the tdegraphics README and SlackBuild
* W_SUDO=ON - set backends for using sudo as the super user command [default is su]
---

***The directory structure*** for the SlackBuild scripts is in line with the Trinity release source repositories:  
```
Deps [dependencies/]
Core [core/]
Libs [libraries/]
Apps [applications/*/]
```
Other directories are:  
```
Misc - for non-Trinity package builds
src - to hold all the sources, either pre-downloaded
      or downloaded during the build.
```
Other scripts:  
```
get-source.sh - common code for the SlackBuilds
              - used for getting the sources, setting FLAGS,
                creating build directories, ...
```
There is an override in the Misc SlackBuilds for non-trinity source archive URLs. Non-trinity builds have been included where a TDE package requires a dependency that is not in Slackware, or where it's an alternative to a TDE package.

Some SlackBuilds require non-Slackware packages which aren't in the build list. These can be added to the build if they are not already installed by downloading the source archives to the 'src' directory. They will then be built and installed during the xxx.SlackBuild.   
See the READMEs in Core/tdeedu, Apps/k3b, Apps/klamav, and Misc/inkscape for details, which can also be viewed while running ./BUILD-TDE.sh.

---

***Required packages*** for a basic working TDE are:  
```
Deps/tqt
Deps/tqtinterface
Deps/arts
Deps/dbus-tqt
Deps/dbus-1-tqt
Deps/tqca
Deps/libart-lgpl
Core/tdelibs
Core/tdebase
```
The cmake-trinity package is downloaded with the first archive, usually tqt.

---

***Internationalization***

i18n support [locale and html/help docs] in the packages is restricted to whatever is selected in the ./BUILD-TDE.sh 'Select Additional Languages' screen and, of that, to whatever is available in any individual package source.

Translations for the .desktop files are determined from the LINGUAS variable which is set in this build shell to the additional languages selected.

There is an option in tde-i18n.SlackBuild to include a user created language specific patch file in the build.  
It needs to be named *tde-i18n-{lang}-patch* and will then automatically be included for the build for that language.  
Because of its position in the Slackbuild and the patch -p0 option, the path to the patched file must start with 'tde-i18n-{lang}' - see tde-i18n-en_GB-patch for an example.

---

***Building the development versions from git sources***

The build is set up to clone the individual TDE apps from trinitydesktop gitea - except for individual language packs of tde-i18n. The whole tde-i18n download is ~1x10^6 bytes, so to reduce that, wget is used to download individual tde-i18n-$lang packs as they are not git repositories.

Once any git repository has been cloned, further downloads are updates only [*[2]*](#git_updates), giving the best options - only fetching what is needed, and incremental updates.

The git repositories are cloned to 'src/cgit'

---
<a id="xcompiling"></a>
***Cross compiling for RPi3***

Cross compiling a number of packages for the Raspberry Pi3 based on these scripts is detailed in the html page in the gh-pages branch:
```
git clone https://github.com/Ray-V/tde-slackbuilds.git  
cd tde-slackbuilds  
git checkout gh-pages
```

which can be [viewed online](https://ray-v.github.io/tde-slackbuilds/cross-compiling-TDE-for-the-RPi3.html).

Includes:
* Setting parameters for a 32-bit [armv7 hard float], or 64-bit [aarch64], build,  
   .. and building ..
*  a cross compiler toolchain
*  a 64-bit kernel which can also be used for the 32-bit system
*  qemu to run the TDE binaries built and used during compilation
*  the required TDE apps
*  a few other TDE and non-TDE apps to provide a basic, but useful, TDE desktop.

---

***Known issues***

[1] TDM may need some manual setting up - see Core/tdebase/README, which can also be viewed while running ./BUILD-TDE.sh if tdebase is selected.

<a id="git_updates"></a>
[2] The i18n downloads with wget for development builds can't be updated because cgit produces 'current time' timestamps. The consequence is that if tde-i18n-$lang is a part of the build after its initial download, it will be downloaded again. As updates are infrequent, once built, there will probably be no need to do so again and so tde-i18n for a particular language will probably only be run once. On that basis I don't see this being a significant issue.

[3] The Misc directory contains SlackBuilds for software that might already be installed from other sources. Please check because any misc builds selected here could overwrite them.

[4] The README for a [native build for Raspberry Pi3](./README-Raspberry-Pi3.md) is out-of-date and cross compiling is a better option.

[5] The options for including features into any build are detailed in the *.SlackBuild - under `../configure` or `cmake -D*`. Those chosen in these scripts are a selection which work for my builds, so if your installation requires a different set of options, the *.SlackBuild should be edited for the option[s] required.

---

See https://wiki.trinitydesktop.org/How_to_Build_TDE_Core_Modules for more information

