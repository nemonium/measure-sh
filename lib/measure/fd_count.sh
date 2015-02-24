#!/bin/bash
#===================================================================================
#
#         FILE: fd_count.sh
#
#        USAGE: fd_count.sh -c condition [-c condition...] [-d delimiter] [-H] [-h]
#
#  DESCRIPTION: Count the number of File Descriptor.
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

  ${0} -c condition [-c condition...] [-d delimiter] [-H] [-h] 

    -d <arg>  : Result delimiter
                default : \\t
    -c <arg>  : ps user defined and condition
                format  : <user-defined>,<condition>
    -H        : Return header only
    -h        : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "c:d:Hh" OPT; do
  case ${OPT} in
    c) CONDITIONS=("${CONDITIONS[@]}" "${OPTARG}");;
    d) DELIMITER="${OPTARG}";;
    H) HEAD=1;;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Return the Header
#-------------------------------------------------------------------------------
if [ "${HEAD}" ]; then
  echo -en "Time"
  for condition in "${CONDITIONS[@]}"
  do
    echo -en "${DELIMITER:-\t}${condition#*:}"
  done
  echo ""
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------

echo -en "${now_time:-`date +%H:%M:%S`}"

for condition in "${CONDITIONS[@]}"
do
  fd_total=0
  for pid in `ps axo pid=,${condition%%,*}= | awk '/'"${condition#*,}"'/ && $1 != PROCINFO["pid"]{print $1}'`
  do
    fd_total=$(( ${fd_total} + `ls -d /proc/${pid}/fd/* 2>/dev/null | wc -l` ))
  done
  echo -en "${DELIMITER:-\t}${fd_total}"
done

echo ""

exit 0
