#!/bin/bash
# pskgen.sh - generates secret keys

# set environment to "C" to avoid i18n processing that confuses tr
LC_ALL=C; LANG=C

# base94 is all of the printable characters (octal range 040-176),
# including the space character, except for the '!' character
# (octal 041)
base94="\040\042-\176"

function usage {
  echo "usage: $0 [-128|-192|-256]";
  echo "  generate random key containing printable characters except !"
  echo "  by default, output is 20 characters (128-bit strength)"
  echo "  -128 causes output of 20 characters (128-bit strength)"
  echo "  -192 causes output of 30 characters (192-bit strength)"
  echo "  -256 causes output of 40 characters (256-bit strength)"
  exit 1
}

hash openssl 2>&- || {
    echo >&2 "error: openssl application not found"
    exit 2;
}

if [ "$#" == "1" ]; then
    if [ "$1" == "-256" ]; then
	keylen=40; # a 256-bit key requires 40 base-94 characters
    elif [ "$1" == "-192" ]; then
	keylen=30; # a 192-bit key requires 30 base-94 characters
    elif [ "$1" == "-128" ]; then
	keylen=20; # a 128-bit key requires 20 base-94 characters
    else
	usage
    fi
elif [ "$#" == "0" ]; then
    keylen=20 # generate a 128-bit key by default
else
    usage
fi

let cropnum=keylen+1; let numbytes=keylen*4
numchars=0
while [ $numchars -lt $keylen ]; do
    X=`openssl rand $numbytes | tr -dc $base94 | colrm $cropnum`
    numchars=${#X}
done
echo "$X"


