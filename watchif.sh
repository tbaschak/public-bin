#!/bin/sh

function usage ()
{
       echo "Usage:"
       echo "    $0 <interface>"
}

if [ $# -ne 1 ]; then
    usage
    exit 127
fi

while true; do
    clear
    ifconfig "$1"
    sleep 1
done

