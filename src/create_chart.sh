#!/bin/bash
#===================================================================================
#
#         FILE: create_chart.sh
#
#        USAGE: create_chart.sh [-o directory] [-c cpuList] [-i i/fList] [-d deviceList] [-m mountedList] [-h]
#
#  DESCRIPTION: Create Visualize Tool
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

  ${0} [-o directory] [-c cpuList] [-i i/fList] [-d deviceList] [-m mountedList] [-h]

    -o <arg> : Specify results directory
               Default : '\$(cd \$(dirname \$0);pwd)/result-\`date +%Y%m%d%H%M%S\`'
                 For example, '$(cd $(dirname $0);pwd)/result-`date +%Y%m%d%H%M%S`'
    -c <arg> : CPU List
    -i <arg> : Interfaces List
    -d <arg> : Device List
    -m <arg> : Mounted List
    -h       : Get help

EOF
exit 0
}

#===  FUNCTION  ================================================================
#         NAME: add_button
#  DESCRIPTION: Add a button to the HTML file.
#===============================================================================
function add_button() {
  tag="###${1}###"
  shift
  uuid=`uuidgen`
  target_id="container_${uuid//-/}"

  val=`echo $@`
  idx=`grep -n ${tag} ${RESULT_DIR}/measure.html  | cut -d: -f1`
  sed -i -e "${idx}i${val/UUID/${target_id}}" ${RESULT_DIR}/measure.html

  c_idx=`grep -n '###CONTAINER###' ${RESULT_DIR}/measure.html  | cut -d: -f1`
  c_val='<div id="UUID" class="measure_container"></div>'
  sed -i -e "${c_idx}i${c_val/UUID/${target_id}}" ${RESULT_DIR}/measure.html
}

UTIL_DIR=$(cd $(dirname $0);pwd)
RESULT_DIR=./result-`date +%Y%m%d%H%M%S`
CONTAINER_IDX=0

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "o:c:i:d:m:h" OPT; do
  case ${OPT} in
    o) RESULT_DIR="${OPTARG}";;
    c) LIST_CPU="${OPTARG}";;
    i) LIST_IF="${OPTARG}";;
    d) LIST_DEV="${OPTARG}";;
    m) LIST_MNT="${OPTARG}";;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

test ! -d ${RESULT_DIR} && mkdir -p ${RESULT_DIR}

cp -p ${UTIL_DIR}/html/measure.html ${RESULT_DIR}
cp -p ${UTIL_DIR}/html/measure.js   ${RESULT_DIR}
cp -p ${UTIL_DIR}/html/measure.css  ${RESULT_DIR}

#-------------------------------------------------------------------------------
# Add a button for viewing memory measure results
#-------------------------------------------------------------------------------
add_button 'MEMORY' '<input class="btn_mem" type="button" target="UUID" src="memory.csv" value="Memory" />'

#-------------------------------------------------------------------------------
# Add a button for viewing CPU measure results
#-------------------------------------------------------------------------------
add_button 'CPU' '<input class="btn_cpu" type="button" target="UUID" src="cpu.all.csv" value="all" />'
for i in ${LIST_CPU[@]}
do
  add_button 'CPU' `echo '<input class="btn_cpu" type="button" target="UUID" src="cpu.###.csv" value="###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Load Average measure results
#-------------------------------------------------------------------------------
add_button 'LOAD_AVERAGE' '<input class="btn_loadavg" type="button" target="UUID" src="loadavg.csv" value="LoadAverage" />'

#-------------------------------------------------------------------------------
# Add a button for viewing Network Traffic measure results
#-------------------------------------------------------------------------------
for i in ${LIST_IF[@]}
do
  add_button 'NETWORK' `echo '<input class="btn_network" type="button" target="UUID" src="network.###.csv" value="###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk IO measure results
#-------------------------------------------------------------------------------
for i in ${LIST_DEV[@]}
do
  add_button 'DISK_IO' `echo '<input class="btn_diskio" type="button" target="UUID" src="diskio.###.csv" value="###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk Util measure results
#-------------------------------------------------------------------------------
for i in ${LIST_DEV[@]}
do
  add_button 'DISK_UTIL' `echo '<input class="btn_diskutil" type="button" target="UUID" src="diskio.###.csv" value="###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk Usage measure results
#-------------------------------------------------------------------------------
for i in ${LIST_MNT[@]}
do
  filename=`echo 'diskuse.%%%.csv' | sed "s/%%%/${i//\//\\_S_}/g"`
  add_button 'DISK_USAGE' `echo '<input class="btn_diskuse" type="button" target="UUID" src="FILE" value="%%%" />' | \
    sed "s/FILE/${filename}/g" | \
    sed "s/%%%/${i//\//\\/}/g"`
done

exit 0
