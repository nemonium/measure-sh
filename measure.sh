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

LIB_DIR=$(cd $(dirname $0);pwd)/lib
RESULT_DIR=./result-`date +%Y%m%d%H%M%S`
INTERVAL=5

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

#-------------------------------------------------------------------------------
# Create CPU list
#-------------------------------------------------------------------------------
LIST_CPU=(`cat /proc/cpuinfo | \
  grep ^processor | \
  awk -v FS=: ' \
    {
      sub (/[ \t]+$/, "", $2);
      sub (/^[ \t]+/, "", $2);
      print $2
    }
  '`)

#-------------------------------------------------------------------------------
# Create Interface list
#-------------------------------------------------------------------------------
LIST_IF=(`ls /proc/sys/net/ipv4/conf/ | \
  grep -v all | \
  grep -v default`)

#-------------------------------------------------------------------------------
# Create Device list
#-------------------------------------------------------------------------------
S_NR=`expr \`iostat -xd | grep -n ^Device: | cut -d: -f1\` + 1`
E_NR=`iostat -xd  | wc -l`
LIST_DEV=(`iostat -xd | \
  awk -v FS=" " -v S=${S_NR} -v E=${E_NR} ' \
    NR==S,NR==E {
      print $1
    }' | \
  grep -v '^$'`)

#-------------------------------------------------------------------------------
# Create Mounted list
#-------------------------------------------------------------------------------
LIST_MNT=(`mount | awk '{print $3}'`)

#-------------------------------------------------------------------------------
# Vabose
#-------------------------------------------------------------------------------
s_time=`date '+%s'`
test ${VERBOSE} && cat <<EOF
Results directory : ${RESULT_DIR}
Measure interval  : ${INTERVAL} sec

Processors        : ${LIST_CPU[@]}
Interfaces        : ${LIST_IF[@]}
IO-devices        : ${LIST_DEV[@]}
Mounted           : ${LIST_MNT[@]}

Start time        : `date --date "@${s_time}"`
EOF

test ${VERBOSE} && test ${END_TIME} && cat << EOF
End time          : `date --date "@${END_TIME}"`
EOF

#-------------------------------------------------------------------------------
# Create Visualize Tool
#-------------------------------------------------------------------------------
sh ${LIB_DIR}/create_chart.sh -o ${RESULT_DIR} \
  -c "${LIST_CPU[*]}" \
  -i "${LIST_IF[*]}" \
  -d "${LIST_DEV[*]}" \
  -m "${LIST_MNT[*]}"

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
    echo -ne "\rElapsed time      : ${now} (${elapsed} sec)" 2>/dev/null

  #-----------------------------------------------------------------------------
  # Measure the usage of memory
  #-----------------------------------------------------------------------------
  sh ${LIB_DIR}/measure_memory.sh -d, -t "$time" >> ${RESULT_DATA_DIR}/memory.csv &

  #-----------------------------------------------------------------------------
  # Measure the usage of CPU
  #-----------------------------------------------------------------------------
  sh ${LIB_DIR}/measure_cpu.sh -d, -t "$time" >> ${RESULT_DATA_DIR}/cpu.all.csv &
  for c in ${LIST_CPU[@]}
  do
    sh ${LIB_DIR}/measure_cpu.sh -c ${c} -d, -t "$time" >> ${RESULT_DATA_DIR}/cpu.${c}.csv &
  done

  #-----------------------------------------------------------------------------
  # Load Average
  #-----------------------------------------------------------------------------
  sh ${LIB_DIR}/measure_loadavg.sh -d, -t "$time" >> ${RESULT_DATA_DIR}/loadavg.csv &

  #-----------------------------------------------------------------------------
  # Measure the traffic of the Network
  #-----------------------------------------------------------------------------
  for i in ${LIST_IF[@]}
  do
    sh ${LIB_DIR}/measure_network.sh -i ${i} -d, -t "$time" >> ${RESULT_DATA_DIR}/network.${i}.csv &
  done

  #-----------------------------------------------------------------------------
  # Disk IO
  #-----------------------------------------------------------------------------
  for i in ${LIST_DEV[@]}
  do
    sh ${LIB_DIR}/measure_diskio.sh -d, -t "$time" ${i} >> ${RESULT_DATA_DIR}/diskio.${i//\//_S_}.csv &
  done

  #-----------------------------------------------------------------------------
  # Disk Use
  #-----------------------------------------------------------------------------
  for i in ${LIST_MNT[@]}
  do
    sh ${LIB_DIR}/measure_diskuse.sh -d, -t "$time" ${i} >> ${RESULT_DATA_DIR}/diskuse.${i//\//_S_}.csv &
  done
done

exit 0
