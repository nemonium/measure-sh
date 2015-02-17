#!/bin/bash
#===================================================================================
#
#         FILE: ps_aggregate.sh
#
#        USAGE: ps_aggregate.sh [-d delimiter] [-D delay] [-H] [-h] condition
#
#  DESCRIPTION: Aggregate the results of ps
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

  ${0} -a user-defined [-f format] -c condition [-c condition...] [-d delimiter] [-H] [-h] 

    -d <arg>  : Result delimiter
                default : \\t
    -a <arg>  : user defined for aggregate
                format  : <user-defined>
    -f <arg>  : aggregate format
                default : %.0f
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
while getopts "a:c:d:f:Hh" OPT; do
  case ${OPT} in
    a) AGGR_ITEM="${OPTARG}";;
    c) CONDITIONS=("${CONDITIONS[@]}" "${OPTARG}");;
    d) DELIMITER="${OPTARG}";;
    f) AGGR_FORMAT="${OPTARG}";;
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
  printf "${DELIMITER:-\t}${AGGR_FORMAT:-%.0f}" \
    `ps axo ${AGGR_ITEM}=,${condition%%,*}= | awk '$2 ~ /'"${condition#*,}"'/{print $1}' | awk '{sum = sum + $0} END {print sum}'`   
done

echo ""

exit 0
