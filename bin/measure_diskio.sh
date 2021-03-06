#!/bin/bash
#===================================================================================
#
#         FILE: measure_diskio.sh
#
#        USAGE: measure_diskio.sh [-d delimiter] [-H] [-h] device
#
#  DESCRIPTION: Measures the Disk IO
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

  ${0} [-d delimiter] [-H] [-h] device

    -d <arg> : Specify delimiter
    -H       : Return header only
    -h       : Get help
    device   : Specify Device

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
  iostat -kxd | \
  awk -v OFS="${D:-\t}" '
    NR==3 { print "Time", $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 }
  '
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
DEV=$1
test ${#DEV} -eq 0 && usage

ret=(`iostat -kxd ${DEV} 5 2 | awk -v DEV=${DEV} 'DEV==$1 {print}' | tail -1`)
test ${#ret} -eq 0 && exit 0
echo ${ret[@]} | \
  awk -v OFS="${D:-\t}" -v TIME="${now_time:-`date +%H:%M:%S`}" '
    { print TIME, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 }
  '

exit 0
