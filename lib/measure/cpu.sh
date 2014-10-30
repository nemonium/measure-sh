#!/bin/bash
#===================================================================================
#
#         FILE: cpu.sh
#
#        USAGE: cpu.sh [-d delimiter] [-c CPU] [-H] [-h]
#
#  DESCRIPTION: Meaures the CPU
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

  ${0} [-d delimiter] [-c CPU] [-H] [-h]

    -d <arg> : Specify delimiter
    -c <arg> : Specify CPU
    -H       : Return header only
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:c:Hh" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
    c) C="${OPTARG}";;
    H) HEAD=1;;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Return the Header
#-------------------------------------------------------------------------------
if [ "${HEAD}" ]; then
  mpstat -P ALL | awk -v OFS="${D:-\t}" '
    $3=="CPU" {
      print "Time", $4, $5, $6, $7, $8, $9, $10, $11, $12
    }
  '
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
mpstat -P ALL 1 1 | \
  grep -v ^Average | \
  awk -v CPUNO=${C:-"all"} -v OFS="${D:-\t}" -v TIME="${now_time:-`date +%H:%M:%S`}" '
    $3==CPUNO {
      print TIME, $4, $5, $6, $7, $8, $9, $10, $11, $12
    }
  '

exit 0
