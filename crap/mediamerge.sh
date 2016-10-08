#!/usr/bin/env bash
# Copyright (c) 2016 Dan Reidy <dubkat@gmail.com>.
# All Rights Reserved.

output="${1:?first arguement should be the name of the output file.}"
shift
list="$@"

file_list="./input.txt"

echo "OUTPUT: $output"
echo "LIST: $list"

ffversion="$(ffmpeg -version | grep version | awk '{ print $3 }')"


if [ ! -e "$file_list" ]; then
  # with a bash for loop
  for f in $list;
    do
      printf "file '%s'\n" $f >> $file_list
  done
fi

ffmpeg -f concat -i $file_list -movflags faststart -map 0 -metadata "encoder='FFmpeg $ffversion'" -c:a copy -c:v copy $output || { echo "Failed."; exit 1; }
rm $file_list
exit 0
