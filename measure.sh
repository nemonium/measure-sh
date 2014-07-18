#!/bin/bash
#===================================================================================
#
#         FILE: measure.sh
#
#        USAGE: measure.sh [-o directory] [-i interval] [-t term] [-h] [-v] [-e]
#
#  DESCRIPTION: Manage each performance measurement script.
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

  ${0} [-o directory] [-i interval] [-t term] [-h] [-v] [-e]

    -o <arg> : Specify results directory
               Default : '\$(cd \$(dirname \$0);pwd)/result-\`date +%Y%m%d%H%M%S\`'
                 For example, '$(cd $(dirname $0);pwd)/result-`date +%Y%m%d%H%M%S`'
    -i <arg> : Specify interval (range 1 .. 60)
               Default : 5
    -t <arg> : Specify measure term
    -e <arg> : End time.
               See the d option of the date command for format.
    -v       : Verbose
    -h       : Get help

EOF
exit 0
}

#===  FUNCTION  ================================================================
#         NAME: search_data_name_list
#  DESCRIPTION: Search data name from measure-map by measure-type
#===============================================================================
function search_data_name_list() {
  grep "^${1}${MAP_DELIMITER}" ${MEASURE_MAP} | awk -v FS=${MAP_DELIMITER} '{print $3}' | tr "\n" ' '
}

LIB_DIR=$(cd $(dirname $0);pwd)/lib

source conf/measure.conf

RESULT_DIR=${RESULT_DIR:-./result-`date +%Y%m%d%H%M%S`}
INTERVAL=${INTERVAL:-5}
MAP_DELIMITER=${MAP_DELIMITER:-:}

#-------------------------------------------------------------------------------
# Use commands check
#-------------------------------------------------------------------------------
sh ${LIB_DIR}/check_commands.sh
test $? -gt 0 && exit 1

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "o:i:t:e:hv" OPT; do
  case ${OPT} in
    o) RESULT_DIR="${OPTARG}";;
    i) INTERVAL="${OPTARG}";;
    t) MEASURE_TERM="${OPTARG}";;
    e) END_TIME="`date -d "${OPTARG}" '+%s' 2>/dev/null`"
       test "${END_TIME}" == "" && usage;;
    v) VERBOSE=1;;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Validation check
#-------------------------------------------------------------------------------
test `expr "${INTERVAL}" : '[0-9]*$'` -eq 0 && usage
test ${INTERVAL} -lt 1  && usage
test ${INTERVAL} -gt 60 && usage
test "${MEASURE_TERM}" && test `expr "${MEASURE_TERM}" : '[0-9]*$'` -eq 0 && usage

#-------------------------------------------------------------------------------
# Make result directory
#-------------------------------------------------------------------------------
test ! -d ${RESULT_DIR} && mkdir -p ${RESULT_DIR}
RESULT_DATA_DIR=${RESULT_DIR}/data
test ! -d ${RESULT_DATA_DIR} && mkdir -p ${RESULT_DATA_DIR}
MEASURE_MAP=${RESULT_DIR}/measure-map

#-------------------------------------------------------------------------------
# Make measure map
#-------------------------------------------------------------------------------
sh ${LIB_DIR}/make_measure_map.sh -d ${MAP_DELIMITER} > ${MEASURE_MAP}

#-------------------------------------------------------------------------------
# Vabose
#-------------------------------------------------------------------------------
s_time=`date '+%s'`
test ${VERBOSE} && cat <<EOF
Results directory   : ${RESULT_DIR}
Measure interval    : ${INTERVAL} sec

Processors          : `search_data_name_list cpu`
Interfaces          : `search_data_name_list network`
Devices             : `search_data_name_list device`
Mounted Directories : `search_data_name_list mount`

Start time          : `date --date "@${s_time}"`
EOF

test ${VERBOSE} && test ${END_TIME} && cat << EOF
End time            : `date --date "@${END_TIME}"`
EOF

#-------------------------------------------------------------------------------
# Create Visualize Tool
#-------------------------------------------------------------------------------
sh ${LIB_DIR}/create_chart.sh -o ${RESULT_DIR} -i ${INTERVAL} -d ${MAP_DELIMITER} ${MEASURE_MAP}

while :
do
  sleep ${INTERVAL}
  time=`date "+%Y-%m-%d %H:%M:%S"`

  e_time=`date '+%s'`
  elapsed=$((${e_time} - ${s_time}))

  #-----------------------------------------------------------------------------
  # If there is a specified for the end time, make the check
  #-----------------------------------------------------------------------------
  test ${END_TIME} && \
    test `date '+%s'` -gt ${END_TIME} && echo "" && exit 0

  #-----------------------------------------------------------------------------
  # If there is a specified number of measurements, make the check
  #-----------------------------------------------------------------------------
  test ${MEASURE_TERM} && \
    test ${elapsed} -gt ${MEASURE_TERM} && echo "" && exit 0

  #-----------------------------------------------------------------------------
  # Outputs elapsed time
  #-----------------------------------------------------------------------------
  test ${VERBOSE} && \
    now=`date --date "@${e_time}"` && \
    echo -ne "\rElapsed time        : ${now} (${elapsed} sec)" 2>/dev/null

  #-----------------------------------------------------------------------------
  # Measure the usage of memory
  #-----------------------------------------------------------------------------
  grep "^memory${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure_memory.sh -d, -t "$time" >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Measure the usage of CPU
  #-----------------------------------------------------------------------------
  grep "^cpu${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    if [ "${name}" == "all" ]; then
      sh ${LIB_DIR}/measure_cpu.sh -d, -t "$time" >> ${RESULT_DIR}/${path} &
    else
      sh ${LIB_DIR}/measure_cpu.sh -c ${name} -d, -t "$time" >> ${RESULT_DIR}/${path} &
    fi
  done

  #-----------------------------------------------------------------------------
  # Load Average
  #-----------------------------------------------------------------------------
  grep "^loadavg${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure_loadavg.sh -d, -t "$time" >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Measure the traffic of the Network
  #-----------------------------------------------------------------------------
  grep "^network${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure_network.sh -i ${name} -d, -t "$time" >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Disk IO
  #-----------------------------------------------------------------------------
  grep "^device${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure_diskio.sh -d, -t "$time" ${name} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Disk Use
  #-----------------------------------------------------------------------------
  grep "^mount${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure_diskuse.sh -d, -t "$time" ${name} >> ${RESULT_DIR}/${path} &
  done
done

exit 0
