#!/bin/bash
#===================================================================================
#
#         FILE: measure_network.sh
#
#        USAGE: measure_network.sh [-d delimiter] [-t time] [-i Interface] [-H] [-h]
#
#  DESCRIPTION: Measures the Network torrific
#
#      OPTIONS: see function ’usage’ below
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Nemonium
#      COMPANY: ---
#      VERSION: 0.9
#      CREATED: 30.10.2013
#     REVISION: ---
#===================================================================================

#===  FUNCTION  ================================================================
#         NAME: usage
#  DESCRIPTION: Display usage information for this script.
#===============================================================================
function usage() {
cat << EOF
Usage:

  ${0} [-d delimiter] [-t time] [-i Interface] [-H] [-h]

    -d <arg> : Specify delimiter
    -t <arg> : Specify date and time to be displayed
    -i <arg> : Specify Interface
    -H       : Return header only
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:t:i:Hh" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
    t) T="${OPTARG}";;
    i) I="${OPTARG}";;
    H) HEAD=1;;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Return the Header
#-------------------------------------------------------------------------------
if [ "${HEAD}" ]; then
  netstat -I"${I:-lo}" | \
    grep ^Iface | \
    awk -v OFS="${D:-\t}" '
      { print "Time", $4, $5, $6, $7, $8, $9, $10, $11 }
    '
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
netstat -I"${I:-lo}" | \
  grep "^${I:-lo}" | \
  awk -v OFS="${D:-\t}" -v TIME="${T:-`date +%H:%M:%S`}" '
    { print TIME, $4, $5, $6, $7, $8, $9, $10, $11 }
  '

exit 0
