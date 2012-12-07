#!/bin/bash

export PATH=/nfs/lis/tools/scripts:${PATH}
source /nfs/lis/tools/Modules/3.2.8/init/bash
source /nfs/labs/scripts/lislab load projlab


impact -batch <<EOT
setMode -bscan
setCable -port auto

addDevice -p 1 -part xc2vp30
addDevice -p 1 -part xccace
addDevice -p 1 -part xcf32p

assignFile -p 3 -file Hardware_TL.bit

Program -p 3

quit
EOT
