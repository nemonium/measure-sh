#!/bin/bash
#===================================================================================
#
#         FILE: measure_map.sh
#
#        USAGE: measure_map.sh [-l path][-d delimiter][-h]
#
#  DESCRIPTION: Make measure map string
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

  ${0} [-l path][-d delimiter][-h]

    -l <arg> : line_count ini file path
    -d <arg> : Delimiter of Result
               Default : ' ' (space)
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "l:d:h" OPT; do
  case ${OPT} in
    l) LINE_COUNT_INI="${OPTARG}";;
    d) DELIMITER="${OPTARG}";;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Define Constant
#-------------------------------------------------------------------------------
DELIMITER=${DELIMITER:- }
RESULT_DATA_DIR=${RESULT_DATA_DIR:-data}
FORMAT="%s${DELIMITER}%s${DELIMITER}%s\n"

printf "${FORMAT}" memory   ${RESULT_DATA_DIR}/memory.csv        Memory
printf "${FORMAT}" loadavg  ${RESULT_DATA_DIR}/loadavg.csv       LoadAverage

#-------------------------------------------------------------------------------
# search processors
#-------------------------------------------------------------------------------
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.all.csv       all
for i in $( sh ${LIB_DIR}/search/processors.sh ); do
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.${i}.csv      ${i}
done

#-------------------------------------------------------------------------------
# search network interfaces
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search/network_ifaces.sh ); do
printf "${FORMAT}" network  ${RESULT_DATA_DIR}/network.${i}.csv  ${i}
done

#-------------------------------------------------------------------------------
# search devices
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search/devices.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" device   ${RESULT_DATA_DIR}/device.${f}.csv   ${i}
done

#-------------------------------------------------------------------------------
# search mounted directories
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search/mounted_dir.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" mount    ${RESULT_DATA_DIR}/mount.${f}.csv    ${i}
done

#-------------------------------------------------------------------------------
# search line count groups
#-------------------------------------------------------------------------------
if [ -f "${LINE_COUNT_INI}" ]; then
  for i in $( egrep "^\[.+\]$" ${LINE_COUNT_INI} | sed "s/^\[\(.*\)\]$/\1/g" ); do
    test "`sh ${LIB_DIR}/make/line_count_condition.sh ${LINE_COUNT_INI} ${i}`" == "" && continue
    printf "${FORMAT}" line_count ${RESULT_DATA_DIR}/line_count.${i}.csv \
      "${i}:`sh ${LIB_DIR}/make/line_count_condition.sh ${LINE_COUNT_INI} ${i}`"
  done
fi

exit 0
