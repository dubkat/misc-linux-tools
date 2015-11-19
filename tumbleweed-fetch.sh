#!/bin/bash

save_dir=/run/media/dubkat/Mobile_Storage

#rm -f ${save_dir}/*.meta4

aria2c -d ${save_dir} --continue=true ${save_dir}/*.meta4

exit $?

