#!/bin/bash
#===================================================================================
#
#         FILE: memory.sh
#
#        USAGE: memory.sh [-d delimiter] [-H] [-h]
#
#  DESCRIPTION: Measures the Memory
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
  vmstat -s | \
    awk -v D="${D:-\t}" -v COL=`vmstat -s | wc -l` -v TIME="${T:-`date +%H:%M:%S`}" '
      BEGIN {
        printf "Time" D
      }
      NR!=COL {
        for ( i = 2; i < NF; i++ ) {
          printf "%s_", $i
        }
        printf $NF D
      }
      NR==COL {
        print $2
      }
    '
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
vmstat -s | \
  awk -v D="${D:-\t}" -v COL=`vmstat -s | wc -l` -v TIME="${now_time:-`date +%H:%M:%S`}" '
    BEGIN {
      printf TIME D
    }
    NR!=COL {
      printf $1 D
    }
    NR==COL {
      print $1
    }
  '

exit 0
