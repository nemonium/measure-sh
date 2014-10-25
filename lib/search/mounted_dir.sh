#!/bin/bash
#===================================================================================
#
#         FILE: mounted_dir.sh
#
#        USAGE: mounted_dir.sh [-d delimiter][-h]
#
#  DESCRIPTION: Search mounted directories.
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
# Search mounted directories
#-------------------------------------------------------------------------------
rt=$(mount | awk '{print $3}')

echo ${rt[@]} | tr ' ' "${DELIMITER:- }"

exit 0
