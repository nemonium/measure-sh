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

  ${0} [-o directory] [-i interval] [-t term] [-h] [-v] [-e] [-l path] [-p path]

    -o <arg> : Specify results directory
               Default : '\$(cd \$(dirname \$0);pwd)/result-\`date +%Y%m%d%H%M%S\`'
                 For example, '$(cd $(dirname $0);pwd)/result-`date +%Y%m%d%H%M%S`'
    -i <arg> : Specify interval (range 1 .. 60)
               Default : 5
    -t <arg> : Specify measure term
    -e <arg> : End time.
               See the d option of the date command for format.
    -l <arg> : line_count ini file path
               Default : '\$(cd \$(dirname \$0);pwd)/conf/measure_line_count.ini'
    -p <arg> : ps_count ini file path
               Default : '\$(cd \$(dirname \$0);pwd)/conf/measure_ps_count.ini'
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

export MEASURE_HOME=$(cd $(dirname $0);pwd)
export LIB_DIR=${MEASURE_HOME}/lib
export CONF_DIR=${MEASURE_HOME}/conf

source ${CONF_DIR}/measure.conf

RESULT_DIR=${RESULT_DIR:-./result-`date +%Y%m%d%H%M%S`}
INTERVAL=${INTERVAL:-5}
MAP_DELIMITER=${MAP_DELIMITER:-:}
MEASURE_LINE_COUNT_INI=${MEASURE_LINE_COUNT_INI:-${CONF_DIR}/measure_line_count.ini}
MEASURE_PS_COUNT_INI=${MEASURE_PS_COUNT_INI:-${CONF_DIR}/measure_ps_count.ini}

#-------------------------------------------------------------------------------
# Use commands check
#-------------------------------------------------------------------------------
sh ${LIB_DIR}/check_commands.sh
test $? -gt 0 && exit 1

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "p:l:o:i:t:e:hv" OPT; do
  case ${OPT} in
    l) MEASURE_LINE_COUNT_INI="${OPTARG}";;
    p) MEASURE_PS_COUNT_INI="${OPTARG}";;
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
sh ${LIB_DIR}/make/measure_map.sh -d ${MAP_DELIMITER} \
  -l ${MEASURE_LINE_COUNT_INI} \
  -p ${MEASURE_PS_COUNT_INI} > ${MEASURE_MAP}

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
  sleep ${INTERVAL} &
  sleep_pid=$!
  export now_time="`date '+%Y-%m-%d %H:%M:%S'`"

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
    sh ${LIB_DIR}/measure/memory.sh -d, >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Measure the usage of CPU
  #-----------------------------------------------------------------------------
  grep "^cpu${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    if [ "${name}" == "all" ]; then
      sh ${LIB_DIR}/measure/cpu.sh -d, >> ${RESULT_DIR}/${path} &
    else
      sh ${LIB_DIR}/measure/cpu.sh -c ${name} -d, >> ${RESULT_DIR}/${path} &
    fi
  done

  #-----------------------------------------------------------------------------
  # Load Average
  #-----------------------------------------------------------------------------
  grep "^loadavg${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure/loadavg.sh -d, >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Measure the traffic of the Network
  #-----------------------------------------------------------------------------
  grep "^network${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure/network.sh -i ${name} -d, >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Disk IO
  #-----------------------------------------------------------------------------
  grep "^device${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure/diskio.sh -d, ${name} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Disk Use
  #-----------------------------------------------------------------------------
  grep "^mount${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    name="`echo ${line} | cut -d ${MAP_DELIMITER} -f3-`"
    sh ${LIB_DIR}/measure/diskuse.sh -d, ${name} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Count the specific line in the file
  #-----------------------------------------------------------------------------
  grep "^line_count${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    condition="`echo ${line} | cut -d ${MAP_DELIMITER} -f4-`"
    sh ${LIB_DIR}/measure/line_count.sh -d, ${condition} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Process count
  #-----------------------------------------------------------------------------
  grep "^ps_count${MAP_DELIMITER}" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d ${MAP_DELIMITER} -f2`"
    conditions=( `echo ${line} | cut -d ${MAP_DELIMITER} -f4- | tr -s '#' ' '` )
    for c in ${conditions[@]}; do
      condition_str="${condition_str} -c ${c}"
    done
    sh ${LIB_DIR}/measure/ps_count.sh -d, ${condition_str} >> ${RESULT_DIR}/${path} &
  done

  wait ${sleep_pid}
done

exit 0
