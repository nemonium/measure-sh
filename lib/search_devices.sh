#!/bin/bash
#===================================================================================
#
#         FILE: search_devices.sh
#
#        USAGE: search_devices.sh [-d delimiter][-h]
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
# Search devices
#-------------------------------------------------------------------------------
s_nr=`expr \`iostat -xd | grep -n ^Device: | cut -d: -f1\` + 1`
e_nr=`iostat -xd  | wc -l`
rt=$(iostat -xd | awk -v FS=" " -v snr=${s_nr} -v enr=${e_nr} '
  NR==snr,NR==enr{
    print $1
  }' | grep -v '^$')

echo ${rt[@]} | tr ' ' "${DELIMITER:- }"

exit 0
