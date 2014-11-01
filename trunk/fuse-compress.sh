#!/bin/bash

COMPRESS_STORAGE=".fuse-compressed"
COMPRESS_METHOD="lzma"
COMPRESS_LEVEL="6"

for x in $(ls -A ${HOME}/${COMPRESS_STORAGE}); do
    fusecompress -c ${COMPRESS_METHOD} -l ${COMPRESS_LEVEL} ${HOME}/${COMPRESS_STORAGE}/${x} ${HOME}/${x}
done



