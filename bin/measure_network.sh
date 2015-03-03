#!/bin/bash
#===================================================================================
#
#         FILE: measure_network.sh
#
#        USAGE: measure_network.sh [-d delimiter] [-i Interface] [-H] [-h]
#
#  DESCRIPTION: Measures the Network torrific
#
#      OPTIONS: see function ’usage’ below
#
#===================================================================================

#===  FUNCTION  ================================================================
#         NAME: usage
#  DESCRIPTION: Display usage information for this script.
#===============================================================================
function usage() {
cat << EOF
Usage:

  ${0} [-d delimiter] [-i Interface] [-H] [-h]

    -d <arg> : Specify delimiter
    -i <arg> : Specify Interface
    -H       : Return header only
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:i:Hh" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
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
  awk -v OFS="${D:-\t}" -v TIME="${now_time:-`date +%H:%M:%S`}" '
    { print TIME, $4, $5, $6, $7, $8, $9, $10, $11 }
  '

exit 0
