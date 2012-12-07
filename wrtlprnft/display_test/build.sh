#!/bin/bash

# to gain passwordless “direct” access to the lab computers, add the following
# to your ~/.ssh/config (replace <user by your LRZ username>):
#
#    host ic
#    hostname prakt08
#    ProxyCommand ssh <user>@ssh.lis.ei.tum.de nc prakt08 22 2>/dev/null
#    user <user>
#
# Then do
#    $ ssh-copy-id <user>@ssh.lis.ei.tum.de
#    $ ssh-copy-id ic
#
# Now you should be able to do
#
#    $ ssh ic
#
# without any password prompts. However, since your public key is stored in
# your home directory and that directory is only mounted after successful
# authentication, you will still need to enter your password if you haven't
# connected to the lab computers for a couple of minutes.

scp ../../src/*.vhd ../../doc/main_pkg.vhd *.vhd ic:lab/Skeleton/Team_Sources/
scp prakt_scripts/*.sh ic:lab/Skeleton/
ssh ic "cd lab/Skeleton; bash ./build.sh" || exit -1
ssh ic "cd lab/Skeleton; bash ./program.sh" || exit -1
