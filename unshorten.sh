#!/bin/bash

function usage ()
{
  echo "Usage:";echo "    $0 <url>"
}
 
if [ $# -ne 1 ]; then
  usage;exit 127
fi

curl -s -o /dev/null --head -w "%{url_effective}\n" -L "$1"
