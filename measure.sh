#!/bin/bash
#===================================================================================
#
#         FILE: measure.sh
#
#        USAGE: measure.sh [-o directory][-i interval][-t term][-h][-v][-e]
#                          [-E extention_measure_config]
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

  ${0} [-o directory][-i interval][-t term][-h][-v][-e]
       [-E extention_measure_config]

    -o <arg> : Specify results directory
               Default : './result-\`date +%Y%m%d%H%M%S\`'
                 For example, './result-`date +%Y%m%d%H%M%S`'
    -i <arg> : Specify interval (range 1 .. 60)
               Default : 5
    -t <arg> : Specify measure term
    -e <arg> : End time.
               See the d option of the date command for format.
    -E <arg> : Extention measures config file path.
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
  grep "^${1}:" ${MEASURE_MAP} | awk -v FS=: '{print $3}' | tr "\n" ' '
}

#-------------------------------------------------------------------------------
# Define Constant
#-------------------------------------------------------------------------------
export TOOL_HOME=$(cd $(dirname $0); pwd)
export PATH=${TOOL_HOME}/bin:${PATH}

source ${TOOL_HOME}/conf/measure.conf

RESULT_DIR=${RESULT_DIR:-./result-`date +%Y%m%d%H%M%S`}
INTERVAL=${INTERVAL:-5}

#-------------------------------------------------------------------------------
# Use commands check
#-------------------------------------------------------------------------------
sh check_commands.sh
test $? -gt 0 && exit 1

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "E:o:i:t:e:hv" OPT; do
  case ${OPT} in
    E) EXTENTION_MEASURES_XML="${OPTARG}";;
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
# Create Visualize Tool
#-------------------------------------------------------------------------------
sh make_measure_map.sh -E "${EXTENTION_MEASURES_XML}" > ${MEASURE_MAP}
sh add_measure_tags.sh -o ${RESULT_DIR} -i ${INTERVAL} ${MEASURE_MAP}

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
# Measurement start
#-------------------------------------------------------------------------------
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
  grep "^memory:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    sh measure_memory.sh -d, >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Measure the usage of CPU
  #-----------------------------------------------------------------------------
  grep "^cpu:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    if [ "${name}" == "all" ]; then
      sh measure_cpu.sh -d, >> ${RESULT_DIR}/${path} &
    else
      sh measure_cpu.sh -c ${name} -d, >> ${RESULT_DIR}/${path} &
    fi
  done

  #-----------------------------------------------------------------------------
  # Load Average
  #-----------------------------------------------------------------------------
  grep "^loadavg:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    sh measure_loadavg.sh -d, >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Measure the traffic of the Network
  #-----------------------------------------------------------------------------
  grep "^network:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    sh measure_network.sh -i ${name} -d, >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Disk IO
  #-----------------------------------------------------------------------------
  grep "^device:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    sh measure_diskio.sh -d, ${name} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Disk Use
  #-----------------------------------------------------------------------------
  grep "^mount:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    sh measure_diskuse.sh -d, ${name} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # inode
  #-----------------------------------------------------------------------------
  grep "^inode:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    name="`echo ${line} | cut -d : -f3-`"
    sh measure_diskuse.sh -i -d, ${name} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Count the specific line in the file
  #-----------------------------------------------------------------------------
  grep "^line_count:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    condition="`echo ${line} | cut -d : -f4-`"
    sh measure_line_count.sh -d, ${condition} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Process count
  #-----------------------------------------------------------------------------
  grep "^ps_count:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    conditions=( `echo ${line} | cut -d : -f4- | tr -s '#' ' '` )
    unset condition_str
    for c in ${conditions[@]}; do
      condition_str="${condition_str} -c ${c}"
    done
    sh measure_ps_count.sh -d, ${condition_str} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # Process aggregate
  #   ps_aggregate:data/ps_aggregate.mem.csv:mem:pmem,%.1f:comm,httpd#comm,bash
  #-----------------------------------------------------------------------------
  grep "^ps_aggregate:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    aggregate=( `echo ${line} | cut -d : -f4` )
    conditions=( `echo ${line} | cut -d : -f5- | tr -s '#' ' '` )
    condition_str="-a ${aggregate%%,*}"
    test "${aggregate#*,}" != "${aggregate}" && condition_str="${condition_str} -f ${aggregate#*,}"
    for c in ${conditions[@]}; do
      condition_str="${condition_str} -c ${c}"
    done
    sh measure_ps_aggregate.sh -d, ${condition_str} >> ${RESULT_DIR}/${path} &
  done

  #-----------------------------------------------------------------------------
  # FD count
  #   fd_count:data/fd_count.fd.csv:fd:comm,sendmail#comm,httpd
  #-----------------------------------------------------------------------------
  grep "^fd_count:" ${MEASURE_MAP} | while read line
  do
    path="`echo ${line} | cut -d : -f2`"
    conditions=( `echo ${line} | cut -d : -f4- | tr -s '#' ' '` )
    unset condition_str
    for c in ${conditions[@]}; do
      condition_str="${condition_str} -c ${c}"
    done
    sh measure_fd_count.sh -d, ${condition_str} >> ${RESULT_DIR}/${path} &
  done

  wait ${sleep_pid}
done

exit 0
