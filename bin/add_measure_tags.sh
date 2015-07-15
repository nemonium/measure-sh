#!/bin/bash
#===================================================================================
#
#         FILE: add_measure_tags.sh
#
#        USAGE: add_measure_tags.sh [-o directory] [-i interval] [-d delimiter] [-h] measure-map
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

  ${0} [-o directory] [-i interval] [-h] measure-map

    -o <arg> : Specify results directory
               Default : \${RESULT_DIR}
    -i <arg> : Interval to aggregate
               Default : 5
    -h       : Get help
    measure-map
             : Format
               <measure-type>:<file-path>:<name>[:<option>]

                 measure-type : Measurement type
                 file-path    : Relative path from the results
                 name         : Measurement item name

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

#-------------------------------------------------------------------------------
# Define Constant
#-------------------------------------------------------------------------------
TOOL_HOME=${TOOL_HOME:-$(cd $(dirname $0)/..; pwd)}
CONTAINER_IDX=0

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "o:i:h" OPT; do
  case ${OPT} in
    o) RESULT_DIR="${OPTARG}";;
    i) INTERVAL="${OPTARG}";;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

MEASURE_MAP=${1}
INTERVAL=${INTERVAL:-5}

if [ ! -f "${MEASURE_MAP}" ]; then
  echo "measure-map does not exist." >&2
  exit 1
fi

if [ "${RESULT_DIR}" == "" ]; then
  echo "Destination is not specified. \`export \${RESULT_DIR}\` or \`-o\` option" >&2
  exit 1
fi

test ! -d "${RESULT_DIR}" && mkdir -p ${RESULT_DIR}
cp -pr ${TOOL_HOME}/view/* ${RESULT_DIR}

#-------------------------------------------------------------------------------
# Add a button for viewing memory measure results
#-------------------------------------------------------------------------------
grep "^memory:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'MEMORY' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_mem" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing CPU measure results
#-------------------------------------------------------------------------------
grep "^cpu:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'CPU' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_cpu" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Load Average measure results
#-------------------------------------------------------------------------------
grep "^loadavg:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'LOAD_AVERAGE' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_loadavg" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Network Traffic measure results
#-------------------------------------------------------------------------------
grep "^network:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'NETWORK' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_network" target="UUID" src="SRC" option="OPT"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g" | \
    sed "s#OPT#${INTERVAL}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk IO measure results
#-------------------------------------------------------------------------------
grep "^device:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'DISK_IO' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_diskio" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk Util measure results
#-------------------------------------------------------------------------------
grep "^device:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'DISK_UTIL' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_diskutil" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk IOPS measure results
#-------------------------------------------------------------------------------
grep "^device:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'DISK_IOPS' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_diskiops" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk Usage measure results
#-------------------------------------------------------------------------------
grep "^mount:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'DISK_USAGE' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_diskuse" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk inode measure results
#-------------------------------------------------------------------------------
grep "^inode:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3-`"
  add_button 'DISK_INODE' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_diskinode" target="UUID" src="SRC"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Line count results
#-------------------------------------------------------------------------------
grep "^line_count:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3`"
  conditions="`echo ${line} | cut -d : -f4- | sed 's/\"/\"\"/g'`"
  add_button 'LINE_COUNT' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_line_count" target="UUID" src="SRC" option="CONDITIONS"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g" | \
    sed "s&CONDITIONS&${conditions}&g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Process count results
#-------------------------------------------------------------------------------
grep "^ps_count:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3`"
  conditions="`echo ${line} | cut -d : -f4- | sed 's/\"/\"\"/g'`"
  add_button 'PS_COUNT' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_ps_count" target="UUID" src="SRC" option="CONDITIONS"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g" | \
    sed "s&CONDITIONS&${conditions}&g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Process aggregate results
#-------------------------------------------------------------------------------
grep "^ps_aggregate:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3`"
  conditions="`echo ${line} | cut -d : -f5- | sed 's/\"/\"\"/g'`"
  add_button 'PS_AGGREGATE' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_ps_aggregate" target="UUID" src="SRC" option="CONDITIONS"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g" | \
    sed "s&CONDITIONS&${conditions}&g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing FD count results
#-------------------------------------------------------------------------------
grep "^fd_count:" ${MEASURE_MAP} | while read line
do
  path="`echo ${line} | cut -d : -f2`"
  name="`echo ${line} | cut -d : -f3`"
  conditions="`echo ${line} | cut -d : -f4- | sed 's/\"/\"\"/g'`"
  add_button 'FD_COUNT' `echo '<span data-toggle="buttons"><label class="btn btn-default btn-xs btn_meas btn_fd_count" target="UUID" src="SRC" option="CONDITIONS"><input type="checkbox"/>VAL</label></span>' | \
    sed "s#SRC#${path}#g" | \
    sed "s#VAL#${name}#g" | \
    sed "s&CONDITIONS&${conditions}&g"`
done

exit 0
