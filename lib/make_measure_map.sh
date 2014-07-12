#!/bin/bash
#===================================================================================
#
#         FILE: make_measure_map.sh
#
#        USAGE: make_measure_map.sh [-d delimiter][-h]
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
# Define Constant
#-------------------------------------------------------------------------------
LIB_DIR=$(cd $(dirname $0);pwd)
DELIMITER=${DELIMITER:- }
RESULT_DATA_DIR=${RESULT_DATA_DIR:-data}
FORMAT="%s${DELIMITER}%s${DELIMITER}%s\n"

printf "${FORMAT}" memory   ${RESULT_DATA_DIR}/memory.csv        Memory
printf "${FORMAT}" loadavg  ${RESULT_DATA_DIR}/loadavg.csv       LoadAverage

#-------------------------------------------------------------------------------
# search processors
#-------------------------------------------------------------------------------
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.all.csv       all
for i in $( sh ${LIB_DIR}/search_processors.sh ); do
printf "${FORMAT}" cpu      ${RESULT_DATA_DIR}/cpu.${i}.csv      ${i}
done

#-------------------------------------------------------------------------------
# search network interfaces
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search_network_ifaces.sh ); do
printf "${FORMAT}" network  ${RESULT_DATA_DIR}/network.${i}.csv  ${i}
done

#-------------------------------------------------------------------------------
# search devices
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search_devices.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" device   ${RESULT_DATA_DIR}/device.${f}.csv   ${i}
done

#-------------------------------------------------------------------------------
# search mounted directories
#-------------------------------------------------------------------------------
for i in $( sh ${LIB_DIR}/search_mounted_dir.sh ); do
f=`echo ${i} | openssl md5 | sed 's/^.* //'`
printf "${FORMAT}" mount    ${RESULT_DATA_DIR}/mount.${f}.csv    ${i}
done

exit 0
