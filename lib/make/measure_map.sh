#!/bin/bash
#===================================================================================
#
#         FILE: measure_map.sh
#
#        USAGE: measure_map.sh [-a paht][-f path][-p path][-l path][-d delimiter][-h]
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

  ${0} [-a paht][-f path][-p path][-l path][-d delimiter][-h]

    -a <arg> : ps_aggregate ini file path
    -f <arg> : fd_count ini file path
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
while getopts "a:p:f:l:d:h" OPT; do
  case ${OPT} in
    a) PS_AGGREGATE_INI="${OPTARG}";;
    p) PS_COUNT_INI="${OPTARG}";;
    f) FD_COUNT_INI="${OPTARG}";;
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
#            condition := <user-defined>,<pattern>
#
#   ex) Input  [ps]
#              condition=comm:sendmail
#              condition=comm:httpd
#       Output ps_count:data/ps_count.ps.csv:ps:comm,sendmail#comm,httpd
#-------------------------------------------------------------------------------
if [ -f "${PS_COUNT_INI}" ]; then
  for i in $( egrep "^\[.+\]$" ${PS_COUNT_INI} | sed "s/^\[\(.*\)\]$/\1/g" ); do
    unset conditions
    for c in $(sh ${LIB_DIR}/utils/read_ini.sh ${PS_COUNT_INI} ${i} condition); do
      conditions=("${conditions[@]}" "${c/:/,}")
    done
    test ${#conditions[@]} -lt 1 && continue
    printf "${FORMAT}" ps_count ${RESULT_DATA_DIR}/ps_count.${i}.csv \
      "${i}:$(IFS=#; echo "${conditions[*]}")"
  done
fi

#-------------------------------------------------------------------------------
# search ps aggregate groups
#   Format : ps_aggregate:<data_path>:<name>:<aggregate>:<condition>[#[condition>...]
#            aggregate := <user-defined>[,<format>]
#            condition := <user-defined>,<pattern>
#
#   ex) Input  [mem]
#              aggregate=pmem:%.1f
#              condition=comm:httpd
#              condition=comm:bash
#       Output ps_aggregate:data/ps_aggregate.mem.csv:mem:pmem,%.1f:comm,httpd#comm,bash
#-------------------------------------------------------------------------------
if [ -f "${PS_AGGREGATE_INI}" ]; then
  for i in $( egrep "^\[.+\]$" ${PS_AGGREGATE_INI} | sed "s/^\[\(.*\)\]$/\1/g" ); do
    unset aggregate
    unset conditions
    for a in $(sh ${LIB_DIR}/utils/read_ini.sh ${PS_AGGREGATE_INI} ${i} aggregate); do
      aggregate="${a/:/,}"
    done
    for c in $(sh ${LIB_DIR}/utils/read_ini.sh ${PS_AGGREGATE_INI} ${i} condition); do
      conditions=("${conditions[@]}" "${c/:/,}")
    done
    test "${aggregate}" == "" && continue
    test ${#conditions[@]} -lt 1 && continue
    printf "${FORMAT}" ps_aggregate ${RESULT_DATA_DIR}/ps_aggregate.${i}.csv \
      "${i}:${aggregate}:$(IFS=#; echo "${conditions[*]}")"
  done
fi

#-------------------------------------------------------------------------------
# search fd count groups
#   Format : fd_count:<data_path>:<name>:<condition>[#[condition>...]
#            condition := <user-defined>,<pattern>
#
#   ex) Input  [fd]
#              condition=comm:sendmail
#              condition=comm:httpd
#       Output fd_count:data/fd_count.fd.csv:fd:comm,sendmail#comm,httpd
#-------------------------------------------------------------------------------
if [ -f "${FD_COUNT_INI}" ]; then
  for i in $( egrep "^\[.+\]$" ${FD_COUNT_INI} | sed "s/^\[\(.*\)\]$/\1/g" ); do
    unset conditions
    for c in $(sh ${LIB_DIR}/utils/read_ini.sh ${FD_COUNT_INI} ${i} condition); do
      conditions=("${conditions[@]}" "${c/:/,}")
    done
    test ${#conditions[@]} -lt 1 && continue
    printf "${FORMAT}" fd_count ${RESULT_DATA_DIR}/fd_count.${i}.csv \
      "${i}:$(IFS=#; echo "${conditions[*]}")"
  done
fi

exit 0
