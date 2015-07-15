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

  ${0} [-h][-c extention_measure_config]

    -c <arg> : extention measures config file
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "c:h" OPT; do
  case ${OPT} in
    c) EXTENTION_MEASURES_XML="${OPTARG}";;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Define Constant
#-------------------------------------------------------------------------------
TOOL_HOME=${TOOL_HOME:-$(cd $(dirname $0)/..; pwd)}
if [[ ":${PATH}:" != *:"${TOOL_HOME}/bin":* ]]; then
  PATH=${TOOL_HOME}/bin:${PATH}
fi
FORMAT="%s:%s:%s\n"

#-------------------------------------------------------------------------------
# Memory
#   Format : memory:<data_path>:<name>
#-------------------------------------------------------------------------------
printf "${FORMAT}" memory   data/memory.csv        Memory

#-------------------------------------------------------------------------------
# LoadAverage
#   Format : loadavg:<data_path>:<name>
#-------------------------------------------------------------------------------
printf "${FORMAT}" loadavg  data/loadavg.csv       LoadAverage

#-------------------------------------------------------------------------------
# search processors
#   Format : cpu:<data_path>:<name>
#-------------------------------------------------------------------------------
printf "${FORMAT}" cpu      data/cpu.all.csv       all
for i in $( sh search_processors.sh ); do
  printf "${FORMAT}" cpu      data/cpu.${i}.csv      ${i}
done

#-------------------------------------------------------------------------------
# search network interfaces
#   Format : network:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh search_network_ifaces.sh ); do
  printf "${FORMAT}" network  data/network.${i}.csv  ${i}
done

#-------------------------------------------------------------------------------
# search partitions
#   Format : device:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh search_partitions.sh ); do
  unset _md5
  _md5=`echo ${i} | md5sum | awk '{print $1}'`
  printf "${FORMAT}" device   data/device.${_md5}.csv   ${i}
done

#-------------------------------------------------------------------------------
# search mounted directories
#   Format : mount:<data_path>:<name>
# ~~~~~
# search mounted directories inode
#   Format : inode:<data_path>:<name>
#-------------------------------------------------------------------------------
for i in $( sh search_mounted_dir.sh ); do
  unset _md5
  _md5=`echo ${i} | md5sum | awk '{print $1}'`
  printf "${FORMAT}" mount    data/mount.${_md5}.csv    ${i}
  printf "${FORMAT}" inode    data/inode.${_md5}.csv    ${i}
done

#-------------------------------------------------------------------------------
# search extention measures group
#   Format : See the extension_measures/make_measure_map*.py header.
#-------------------------------------------------------------------------------
if [[ -f ${EXTENTION_MEASURES_XML} ]]; then
  ls ${TOOL_HOME}/bin/extension_measures/make_measure_map*.py | while read script
  do
    python ${script} -c ${EXTENTION_MEASURES_XML}
  done
fi

exit 0
