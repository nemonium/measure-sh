#!/bin/bash
#===================================================================================
#
#         FILE: measure_cpu.sh
#
#        USAGE: measure_cpu.sh [-d delimiter] [-t time] [-c CPU] [-H] [-h]
#
#  DESCRIPTION: Meaures the CPU
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

  ${0} [-d delimiter] [-t time] [-c CPU] [-H] [-h]

    -d <arg> : Specify delimiter
    -t <arg> : Specify date and time to be displayed
    -c <arg> : Specify CPU
    -H       : Return header only
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:t:c:Hh" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
    t) T="${OPTARG}";;
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
# Measures the CPU
#-------------------------------------------------------------------------------
mpstat -P ALL 1 1 | \
  grep -v ^Average | \
  awk -v CPUNO=${C:-"all"} -v OFS="${D:-\t}" -v TIME="${T:-`date +%H:%M:%S`}" '
    $3==CPUNO {
      print TIME, $4, $5, $6, $7, $8, $9, $10, $11, $12
    }
  '

exit 0
