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

  ${0} [-p path][-l path][-d delimiter][-h]

    -p <arg> : ps_count ini file path
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
while getopts "p:l:d:h" OPT; do
  case ${OPT} in
    p) PS_COUNT_INI="${OPTARG}";;
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

#-------------------------------------------------------------------------------
# Memory
#   Format : memory:<data_path>:<name>
#-------------------------------------------------------------------------------
printf "${FORMAT}" memory   ${RESULT_DATA_DIR}/memory.csv        Memory

#-------------------------------------------------------------------------------
# LoadAverage
#   Format : loadavg:<data_path>:<name>
#-------------------------------------------------------------------------------
printf "${FORMAT}" loadavg  ${RESULT_DATA_DIR}/loadavg.csv       LoadAverage

#-------------------------------------------------------------------------------
# search processors
#   Format : cpu:<data_path>:<name>
#-------------------------------------------------------------------------------
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.all.csv       all
for i in $( sh ${LIB_DIR}/search/processors.sh ); do
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.${i}.csv      ${i}
done

#-------------------------------------------------------------------------------
# search network interfaces
#   Format : network:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search/network_ifaces.sh ); do
printf "${FORMAT}" network  ${RESULT_DATA_DIR}/network.${i}.csv  ${i}
done

#-------------------------------------------------------------------------------
# search devices
#   Format : device:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search/devices.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" device   ${RESULT_DATA_DIR}/device.${f}.csv   ${i}
done

#-------------------------------------------------------------------------------
# search mounted directories
#   Format : mount:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search/mounted_dir.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" mount    ${RESULT_DATA_DIR}/mount.${f}.csv    ${i}
done

#-------------------------------------------------------------------------------
# search line count groups
#   Format : line_count:<data_path>:<name>:<target_file>:<pattern>[#<pattern>...]
#
#   ex) Input  [dsn]
#              file=/var/log/maillog
#              condition=client=
#              condition=dsn=2
#              condition=dsn=4
#              condition=dsn=5
#       Output line_count:data/line_count.dsn.csv:dsn:/var/log/maillog:client=#dsn=2#dsn=4#dsn=5
#-------------------------------------------------------------------------------
if [ -f "${LINE_COUNT_INI}" ]; then
  for i in $( egrep "^\[.+\]$" ${LINE_COUNT_INI} | sed "s/^\[\(.*\)\]$/\1/g" ); do
    test "`sh ${LIB_DIR}/make/line_count_condition.sh ${LINE_COUNT_INI} ${i}`" == "" && continue
    printf "${FORMAT}" line_count ${RESULT_DATA_DIR}/line_count.${i}.csv \
      "${i}:`sh ${LIB_DIR}/make/line_count_condition.sh ${LINE_COUNT_INI} ${i}`"
  done
fi

#-------------------------------------------------------------------------------
# search ps count groups
#   Format : ps_count:<data_path>:<name>:<condition>[#[condition>...]
#            condition := <user-define>,<pattern>
#
#   ex) Input  [ps]
#              condition=comm:sendmail
#              condition=comm:httpd
#       Output ps_count:data/ps_count.ps.csv:ps:comm,sendmail#comm,httpd
#-------------------------------------------------------------------------------
if [ -f "${PS_COUNT_INI}" ]; then
  for i in $( egrep "^\[.+\]$" ${PS_COUNT_INI} | sed "s/^\[\(.*\)\]$/\1/g" ); do
    for c in $(sh ${LIB_DIR}/utils/read_ini.sh conf/measure_ps_count.ini ${i} condition); do
      conditions=("${conditions[@]}" "${c/:/,}")
    done
    test ${#conditions[@]} -lt 1 && continue
    printf "${FORMAT}" ps_count ${RESULT_DATA_DIR}/ps_count.${i}.csv \
      "${i}:$(IFS=#; echo "${conditions[*]}")"
  done
fi

exit 0
