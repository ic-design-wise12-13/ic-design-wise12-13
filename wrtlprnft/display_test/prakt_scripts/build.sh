#!/bin/bash

export PATH=/nfs/lis/tools/scripts:${PATH}
source /nfs/lis/tools/Modules/3.2.8/init/bash
source /nfs/labs/scripts/lislab load projlab

xst -ise "/home/gu62cav/lab/Skeleton/Praktikum.ise" -intstyle ise -ifn "/home/gu62cav/lab/Skeleton/Hardware_TL.xst" -ofn "/home/gu62cav/lab/Skeleton/Hardware_TL.syr" || exit 1
ngdbuild -ise "/home/gu62cav/lab/Skeleton/Praktikum.ise" -intstyle ise -dd _ngo  -nt timestamp -i -p xc2vp30-ff896-7 "Hardware_TL.ngc" Hardware_TL.ngd || exit 1
map -ise "/home/gu62cav/lab/Skeleton/Praktikum.ise" -intstyle ise -p xc2vp30-ff896-7 -cm area -pr off -k 4 -c 100 -tx off -o Hardware_TL_map.ncd Hardware_TL.ngd Hardware_TL.pcf || exit 1
par -ise "/home/gu62cav/lab/Skeleton/Praktikum.ise" -w -intstyle ise -ol std -t 1 Hardware_TL_map.ncd Hardware_TL.ncd Hardware_TL.pcf || exit 1
trce -ise "/home/gu62cav/lab/Skeleton/Praktikum.ise" -intstyle ise -v 3 -s 7 -xml Hardware_TL Hardware_TL.ncd -o Hardware_TL.twr Hardware_TL.pcf -ucf hardware_tl.ucf || exit 1
bitgen -ise "/home/gu62cav/lab/Skeleton/Praktikum.ise" -intstyle ise -f Hardware_TL.ut Hardware_TL.ncd || exit 1
