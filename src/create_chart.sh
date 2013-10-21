#!/bin/bash

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

function addScript() {
  val=`echo $@`
  idx=`grep -n '#####SCRIPT(E)#####' ${RESULT_DIR}/measure.html  | cut -d: -f1`
  sed -i -e "${idx}i${val}" ${RESULT_DIR}/measure.html
}

function addButton() {
  val=`echo $@`
  idx=`grep -n '#####BUTTON(E)#####' ${RESULT_DIR}/measure.html  | cut -d: -f1`
  sed -i -e "${idx}i${val}" ${RESULT_DIR}/measure.html
}

UTIL_DIR=$(cd $(dirname $0);pwd)
RESULT_DIR=./result-`date +%Y%m%d%H%M%S`

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

### Javascript
addScript '$("#memory").click(function() { createChartOfMemory("memory.csv"); });'
addScript '$("#cpu_all").click(function() { createChartOfCpu("cpu.all.csv"); });'
for i in ${LIST_CPU[@]}
do
  addScript `echo '$("#cpu_###").click(function() { createChartOfCpu("cpu.###.csv"); });' | sed "s/###/$i/g"`
done
addScript '$("#loadavg").click(function() { createChartOfLoadavg("loadavg.csv"); });'
for i in ${LIST_IF[@]}
do
  addScript `echo '$("#network_###").click(function() { createChartOfNetwork("network.###.csv"); });' | sed "s/###/$i/g"`
done
for i in ${LIST_DEV[@]}
do
  addScript `echo '$("#diskio_###").click(function() { createChartOfDiskIO("diskio.###.csv"); });' | sed "s/###/$i/g"`
  addScript `echo '$("#diskutil_###").click(function() { createChartOfDiskUtil("diskio.###.csv"); });' | sed "s/###/$i/g"`
done
for i in ${LIST_MNT[@]}
do
  addScript `echo '$("#diskuse_###").click(function() { createChartOfDiskUsage("diskuse.%%%.csv"); });' | \
    sed "s/###/${i//\//}/g" | \
    sed "s/%%%/${i//\//\\_S_}/g"`
done

### Html
addButton '<input id="memory" type="button" value="Memory" />'
addButton '<input id="cpu_all" type="button" value="Cpu - all" />'

for i in ${LIST_CPU[@]}
do
  addButton `echo '<input id="cpu_###" type="button" value="Cpu - ###" />' | sed "s/###/$i/g"`
done
addButton '<input id="loadavg" type="button" value="LoadAverage" />'

for i in ${LIST_IF[@]}
do
  addButton `echo '<input id="network_###" type="button" value="Network - ###" />' | sed "s/###/$i/g"`
done

for i in ${LIST_DEV[@]}
do
  addButton `echo '<input id="diskio_###" type="button" value="DiskIO - ###" />' | sed "s/###/$i/g"`
done

for i in ${LIST_DEV[@]}
do
  addButton `echo '<input id="diskutil_###" type="button" value="DiskUtil - ###" />' | sed "s/###/$i/g"`
done

for i in ${LIST_MNT[@]}
do
  addButton `echo '<input id="diskuse_###" type="button" value="DiskUsage - %%%" />' | \
    sed "s/###/${i//\//}/g" | \
    sed "s/%%%/${i//\//\\/}/g"`
done

exit 0
