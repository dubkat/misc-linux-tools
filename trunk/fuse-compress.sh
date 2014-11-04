#!/bin/bash
# Create an accesable compressed filesystem using FUSE.
# Copyleft (C) 2014 Dan Reidy <dubkat@gmail.com>
# $Id$
#
# Note: Intended for /home use, but can be easily adapted for system use at your own risk.
#

COMPRESS_STORAGE=".fuse-compressed"
COMPRESS_METHOD="lzma"
COMPRESS_LEVEL="6"

for x in $(ls -A ${HOME}/${COMPRESS_STORAGE}); do
    fusecompress -c ${COMPRESS_METHOD} -l ${COMPRESS_LEVEL} ${HOME}/${COMPRESS_STORAGE}/${x} ${HOME}/${x}
done



