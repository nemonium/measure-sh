#!/bin/bash
#===================================================================================
#
#         FILE: search_partitions.sh
#
#        USAGE: search_partitions.sh [-d delimiter][-h]
#
#  DESCRIPTION: Search device list.
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

  ${0} [-d delimiter][-h]

    -d <arg> : Delimiter of Result
               Default : ' ' (space)
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:h" OPT; do
  case ${OPT} in
    d) DELIMITER="${OPTARG}";;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Search partitions
#-------------------------------------------------------------------------------
partitions=`cat /proc/partitions | awk 'NR>2{print $4}'`
echo ${partitions[@]} | tr ' ' "${DELIMITER:- }"

exit 0
