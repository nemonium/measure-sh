#!/bin/bash
#===================================================================================
#
#         FILE: loadavg.sh
#
#        USAGE: loadavg.sh [-d delimiter] [-H] [-h]
#
#  DESCRIPTION: Measures the Load Average
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

  ${0} [-d delimiter] [-H] [-h]

    -d <arg> : Specify delimiter
    -H       : Return header only
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:Hh" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
    H) HEAD=1;;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Return the Header
#-------------------------------------------------------------------------------
if [ "${HEAD}" ]; then
  echo -e "Time${D:-\t}1min${D:-\t}5min${D:-\t}15min"
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
cat /proc/loadavg | \
  awk -v OFS="${D:-\t}" -v TIME="${now_time:-`date +%H:%M:%S`}" '
    { print TIME, $1, $2, $3 }
  '

exit 0
