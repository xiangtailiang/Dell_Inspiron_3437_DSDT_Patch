#!/bin/bash

SUDO=sudo
TAG=tag_file
TAGCMD=`pwd`/tools/tag
SLE=/System/Library/Extensions
LE=/Library/Extensions


# extract minor version (eg. 10.9 vs. 10.10 vs. 10.11)
MINOR_VER=$([[ "$(sw_vers -productVersion)" =~ [0-9]+\.([0-9]+) ]] && echo ${BASH_REMATCH[1]})

# install to /Library/Extensions for 10.11 or greater
if [[ $MINOR_VER -ge 11 ]]; then
    KEXTDEST=$LE
else
    KEXTDEST=$SLE
fi

# this could be removed if 'tag' can be made to work on old systems
function tag_file
{
    if [[ $MINOR_VER -ge 9 ]]; then
        $SUDO $TAGCMD "$@"
    fi
}


function _install_kext
{
    if [ "$1" != "" ]; then
        echo installing $1 to $KEXTDEST
        $SUDO rm -Rf $SLE/`basename $1` $KEXTDEST/`basename $1`
        $SUDO cp -Rf $1 $KEXTDEST
        $TAG -a Gray $KEXTDEST/`basename $1`
        $SUDO chmod -R 755 $KEXTDEST/`basename $1`
        $SUDO chown -R root:wheel $KEXTDEST/`basename $1`
    fi
}



#install kext to SLE or LE
cd ./kexts 
for kext in *.kext; do
    _install_kext $kext
done

# force cache rebuild with output
$SUDO touch $SLE && $SUDO kextcache -u /





