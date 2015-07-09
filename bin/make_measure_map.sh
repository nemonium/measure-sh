#!/bin/bash
#===================================================================================
#
#         FILE: make_measure_map.sh
#
#        USAGE: make_measure_map.sh [-d delimiter][-h][-c extention_measure_config]
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

  ${0} [-d delimiter][-h][-c extention_measure_config]

    -c <arg> : extention measures config file
               default : ../conf/extension_measures.xml
    -d <arg> : Delimiter of Result
               Default : ' ' (space)
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "c:d:h" OPT; do
  case ${OPT} in
    c) EXTENTION_MEASURES_XML="${OPTARG}";;
    d) DELIMITER="${OPTARG}";;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Define Constant
#-------------------------------------------------------------------------------
PWD=$(cd $(dirname $0);pwd)
EXTENTION_MEASURES_XML=${EXTENTION_MEASURES_XML:-${PWD}/../conf/extension_measures.xml}
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
for i in $( sh ${TOOL_BIN_DIR}/search_processors.sh ); do
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.${i}.csv      ${i}
done

#-------------------------------------------------------------------------------
# search network interfaces
#   Format : network:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh ${TOOL_BIN_DIR}/search_network_ifaces.sh ); do
printf "${FORMAT}" network  ${RESULT_DATA_DIR}/network.${i}.csv  ${i}
done

#-------------------------------------------------------------------------------
# search partitions
#   Format : device:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh ${TOOL_BIN_DIR}/search_partitions.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" device   ${RESULT_DATA_DIR}/device.${f}.csv   ${i}
done

#-------------------------------------------------------------------------------
# search mounted directories
#   Format : mount:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh ${TOOL_BIN_DIR}/search_mounted_dir.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" mount    ${RESULT_DATA_DIR}/mount.${f}.csv    ${i}
done

#-------------------------------------------------------------------------------
# search extention measures group
#   Format : See the extension_measures/make_measure_map*.py header.
#-------------------------------------------------------------------------------
ls ${TOOL_BIN_DIR}/extension_measures/make_measure_map*.py | while read script
do
  python ${script} -c ${EXTENTION_MEASURES_XML}
done

exit 0
