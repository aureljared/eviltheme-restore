# Eviltheme by Jared Dantis (@aureljared)
# Licensed under GPL v3
# https://github.com/aureljared/eviltheme
OUTFD=/proc/self/fd/$2

# Embedded mode support (from @osm0sis)
readlink /proc/$$/fd/$2 2>/dev/null | grep /tmp >/dev/null;
if [ "$?" -eq "0" ]; then
    # rerouted to log file, so suppress recovery ui commands
    OUTFD=/proc/self/fd/0
    # try to find the actual fd (pipe with parent updater likely started as 'update-binary 3 fd zipfile')
    for FD in $(ls /proc/$$/fd); do
        readlink /proc/$$/fd/$FD 2>/dev/null | grep pipe >/dev/null
        if [ "$?" -eq "0" ]; then
            ps | grep " 3 $FD " | grep -v grep >/dev/null
            if [ "$?" -eq "0" ]; then
                OUTFD=/proc/self/fd/$FD
                break
            fi
        fi
    done
fi

# Print to recovery UI
#   ui_print "Hello!"
ui_print() { echo "ui_print ${1} " >> $OUTFD; }

# Detect dual /system partitions
[ -d "/system/system" ] && ROOT="/system" || ROOT=""

# Getprop
getProperty() {
    propVal=$(cat $ROOT/system/build.prop | grep "^${1}=" | cut -d"=" -f2 | tr -d '\r ')
    echo "$propVal"
}

# Get architecture
# Adapted from Magisk's util_functions.sh
ABI=`getProperty ro.product.cpu.abi | cut -c-3`
ABI2=`getProperty ro.product.cpu.abi2 | cut -c-3`
ABILONG=`getProperty ro.product.cpu.abi`
ARCH=arm
IS64BIT=false
if [ "$ABI" = "x86" ]; then ARCH=x86; fi;
if [ "$ABI2" = "x86" ]; then ARCH=x86; fi;
if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm64; IS64BIT=true; fi;
if [ "$ABILONG" = "x86_64" ]; then ARCH=x64; IS64BIT=true; fi;

