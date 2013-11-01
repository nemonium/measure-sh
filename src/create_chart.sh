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
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Nemonium
#      COMPANY: ---
#      VERSION: 0.9
#      CREATED: 30.10.2013
#     REVISION: ---
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
  val=`echo $@`
  idx=`grep -n '#####BUTTON(E)#####' ${RESULT_DIR}/measure.html  | cut -d: -f1`
  sed -i -e "${idx}i${val}" ${RESULT_DIR}/measure.html
}

UTIL_DIR=$(cd $(dirname $0);pwd)
RESULT_DIR=./result-`date +%Y%m%d%H%M%S`

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

#-------------------------------------------------------------------------------
# Add a button for viewing memory measure results
#-------------------------------------------------------------------------------
add_button '<input class="btn_mem" type="button" src="memory.csv" value="Memory" />'

#-------------------------------------------------------------------------------
# Add a button for viewing CPU measure results
#-------------------------------------------------------------------------------
add_button '<input class="btn_cpu" type="button" src="cpu.all.csv" value="Cpu - all" />'
for i in ${LIST_CPU[@]}
do
  add_button `echo '<input class="btn_cpu" type="button" src="cpu.###.csv" value="Cpu - ###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Load Average measure results
#-------------------------------------------------------------------------------
add_button '<input class="btn_loadavg" type="button" src="loadavg.csv" value="LoadAverage" />'

#-------------------------------------------------------------------------------
# Add a button for viewing Network Traffic measure results
#-------------------------------------------------------------------------------
for i in ${LIST_IF[@]}
do
  add_button `echo '<input class="btn_network" type="button" src="network.###.csv" value="Network - ###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk IO measure results
#-------------------------------------------------------------------------------
for i in ${LIST_DEV[@]}
do
  add_button `echo '<input class="btn_diskio" type="button" src="diskio.###.csv" value="DiskIO - ###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk Util measure results
#-------------------------------------------------------------------------------
for i in ${LIST_DEV[@]}
do
  add_button `echo '<input class="btn_diskutil" type="button" src="diskio.###.csv" value="DiskUtil - ###" />' | sed "s/###/$i/g"`
done

#-------------------------------------------------------------------------------
# Add a button for viewing Disk Usage measure results
#-------------------------------------------------------------------------------
for i in ${LIST_MNT[@]}
do
  filename=`echo 'diskuse.%%%.csv' | sed "s/%%%/${i//\//\\_S_}/g"`
  add_button `echo '<input class="btn_diskuse" type="button" src="FILE" value="DiskUsage - %%%" />' | \
    sed "s/FILE/${filename}/g" | \
    sed "s/%%%/${i//\//\\/}/g"`
done

exit 0
