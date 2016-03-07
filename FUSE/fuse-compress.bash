#!/bin/bash
# Create an accesable compressed filesystem using FUSE.
# Copyleft (C) 2014 Dan Reidy <dubkat@gmail.com>
# $Id$
#
# Note: Intended for /home use, but can be easily adapted for system use at your own risk.
#

COMPRESS_STORAGE=".fuse-compressed"
COMPRESS_METHOD="fc_c:lzma"
#COMPRESS_LEVEL="6"

for x in $(/bin/ls -A ${HOME}/${COMPRESS_STORAGE}); do
    fusecompress -o ${COMPRESS_METHOD},allow_root ${HOME}/${COMPRESS_STORAGE}/${x} ${HOME}/${x}
done



