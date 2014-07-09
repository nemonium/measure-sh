#!/bin/bash
#===================================================================================
#
#         FILE: search_processors.sh
#
#        USAGE: search_processors.sh [-d delimiter][-h]
#
#  DESCRIPTION: Search cpu processor list.
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
# Search processors
#-------------------------------------------------------------------------------
rt=$(cat /proc/cpuinfo | grep ^processor | awk -v FS=: '
  {
    sub (/[ \t]+$/, "", $2);
    sub (/^[ \t]+/, "", $2);
    print $2
  }')

echo ${rt[@]} | tr ' ' "${DELIMITER:- }"

exit 0
