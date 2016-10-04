# KDE Frameworks 5
## CompressNG Service Menu for Dolphin.

### Welcome to the 21st Century.

Have you noticed that the KDE menus when you right click, can be a little obsolete? Compress with gzip? seriously? I haven't "gzipped" something in almost a decade. Well this lonesome opendesktop file has magical powers. 

In Dolphin, you can disable the old, outdated "Compress" menu that is still being distributed (under services), and use this wonderful tool instead. Currently it support XZ, LZMA, Bzip2. I'll be adding support for more tools soon.


### KDE Frameworks 5

*Ark* 16.08.1, and *Dolphin* 16.08.1.

````

INSTALLDIR="$(xdg-user-dir HOME)/.local/share/kservices5/ServicesMenus"

mkdir -p "${INSTALLDIR}" 2>/dev/null ||:
kdecp5 dolphin_compress_ng.desktop "${INSTALLDIR}"

unset INSTALLDIR

````

For all your users enjoyment, stick it in
`/usr/share/kservices5/ServicesMenus`

### KDE 4.14

````

# this is not a typo :)
INSTALLDIR="$(kde4-config --localprefix)share/kde4/services/ServiceMenus"

mkdir -p "${INSTALLDIR}" 2>/dev/null ||:
kde-cp dolphin_compress_ng.desktop "${INSTALLDIR}"
unset INSTALLDIR

````

Enjoy. 