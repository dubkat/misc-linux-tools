#!/bin/bash
#
# move ~/.kde4/share/icons/xxx to ~/.icons. 
# this will save our icons from distruction when the enevitable wipe out of our .kde4 directory
# happens.
#
# Copyleft (C) 2014 Dan Reidy <dubkat@gmail.com>
# $Id$



LOCAL_ICONS="${HOME}/.local/share/icons"

kdedir=$(kde4-config --localprefix);
kicons="${kdedir}/share/icons"

for icons in $(ls $kicons); do 
	if [ -d ${kicons}/${icons} ]; then
		mv ${kicons}/${icons} ${LOCAL_ICONS}/${icons}
	fi
done



