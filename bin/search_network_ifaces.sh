#!/bin/bash
#===================================================================================
#
#         FILE: search_network_ifaces.sh
#
#        USAGE: search_network_ifaces.sh [-d delimiter][-h]
#
#  DESCRIPTION: Search network interfacei list.
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
# Search network interface
#-------------------------------------------------------------------------------
rt=$(ls /proc/sys/net/ipv4/conf/ | grep -v all | grep -v default)

echo ${rt[@]} | tr ' ' "${DELIMITER:- }"

exit 0
