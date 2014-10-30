#!/bin/bash
#===================================================================================
#
#         FILE: diskuse.sh
#
#        USAGE: diskuse.sh [-d delimiter] [-H] [-h] mounted
#
#  DESCRIPTION: Measures the Disk Use
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

  ${0} [-d delimiter] [-H] [-h] mounted

    -d <arg> : Specify delimiter
    -H       : Return header only
    -h       : Get help
    mounted  : Specify Device

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
  df | \
  awk -v OFS="${D:-\t}" '
    NR==1 { print "Time", $2, $3, $4, $5 }
  '
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
MNT=$1
test ${#MNT} -eq 0 && usage

ret=(`df ${MNT} | awk 'NR>=2 {print}'`)
test ${#ret} -eq 0 && exit 0
echo ${ret[@]} | \
  awk -v OFS="${D:-\t}" -v TIME="${now_time:-`date +%H:%M:%S`}" '
    { print TIME, $2, $3, $4, $5 }
  '

exit 0
