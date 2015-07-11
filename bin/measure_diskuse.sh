#!/bin/bash
#===================================================================================
#
#         FILE: measure_diskuse.sh
#
#        USAGE: measure_diskuse.sh [-d delimiter] [-H] [-h] [-i] mounted
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

  ${0} [-d delimiter] [-H] [-h] [-i] mounted

    -d <arg> : Specify delimiter
    -H       : Return header only
    -h       : Get help
    -i       : inode
    mounted  : Specify Device

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
unset inode
while getopts "d:Hhi" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
    H) HEAD=1;;
    i) inode="-i";;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Return the Header
#-------------------------------------------------------------------------------
if [ "${HEAD}" ]; then
  df ${inode} | \
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

df ${inode} -P ${MNT} | tail -1 | \
  awk -v OFS="${D:-\t}" -v TIME="${now_time:-`date +%H:%M:%S`}" '
    { print TIME, $2, $3, $4, $5 }
  '

exit 0
