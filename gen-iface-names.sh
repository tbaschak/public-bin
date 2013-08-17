#!/bin/sh

# router name generator
# [ omachonu ogali / oogali at blip dot tv / @oogali ]
# originally from: https://gist.github.com/oogali/778830
#
# Modified by Theo Baschak for BSD / OSX
# theo at voinetworks dot ca @voinetstatus
#
# README:
#  1. point at your router with a community
#  2. finesse names as needed into your DNS zones
#  3. have a cold beverage of your choosing.
#
# Example run:
#  $ ./gen-iface-names.sh cr1.nyc2 s3kr1t mynetwork.com
#  gi1-23.cr1.nyc2.mynetwork.com: 10.20.30.2
#  gi4-5.cr1.nyc2.mynetwork.com: 172.16.248.2
#  lo0.cr1.nyc2.mynetwork.com: 192.168.255.12
#

SNMPGET=`which snmpget 2>/dev/null`
SNMPWALK=`which snmpwalk 2>/dev/null`
if [ -z "${SNMPGET}" ] || [ -z "${SNMPWALK}" ]; then
  echo "$0: could not find net-snmp installation"
  exit 1
fi

SNMPBIN_FLAGS="-Oq -On"
SNMPBIN_VALUE_FLAG="-Ov"

HOSTNAME_OID=".1.3.6.1.2.1.1.5.0"
IFDESCR_OID=".1.3.6.1.2.1.2.2.1.2"
ADDRESSES_OID=".1.3.6.1.2.1.4.20.1.2"

if [ $# -lt 2 ]; then
  echo "$0 <ip address/hostname> <snmp community> [domain name]"
  exit 1
fi

router=$1
comm=$2
domain=$3
SNMPBIN_FLAGS="${SNMPBIN_FLAGS} -v1 -c ${comm} ${router}"

# grab router name
rname=`${SNMPGET} ${SNMPBIN_VALUE_FLAG} ${SNMPBIN_FLAGS} ${HOSTNAME_OID}`
if [ -z "${rname}" ]; then
  echo "$0: could not get router's hostname. check ip and/or community string"
  exit 1
fi

# append domain to router name if we only get 1 dot
if [ ! -z "${domain}" ] && [ "`echo -n "${rname}" | sed 's/[^\.]//g' | wc -c`" -eq 1 ]; then
  rname="${rname}.${domain}"
fi

# loop through each IP address on the router
for entry in `${SNMPWALK} ${SNMPBIN_FLAGS} ${ADDRESSES_OID} | sed "s/^${ADDRESSES_OID}\.//g; s/ /|/"` ; do
  ip=`echo ${entry} | cut -f1 -d '|'`
  ifindex=`echo ${entry} | cut -f2 -d '|'`
  ifname=`${SNMPGET} ${SNMPBIN_VALUE_FLAG} ${SNMPBIN_FLAGS} ${IFDESCR_OID}.${ifindex}`

  echo "${ifname}" | sed 's/^\([A-Za-z][A-Za-z]\)[A-Za-z]*/\1/g; s/\//-/g; s/\(.*\)\.\(.*\)/\2.\1/' | tr '[A-Z]' '[a-z]' | sed "s/\$/.${rname}: ${ip}/"
done | sort -n
