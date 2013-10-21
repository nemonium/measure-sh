#!/bin/bash

function usage() {
cat << EOF
Usage:

  ${0} [-d delimiter] [-t time] [-H] [-h] mounted

    -d <arg> : Specify delimiter
    -t <arg> : Specify date and time to be displayed
    -H       : Return header only
    -h       : Get help

    mounted  : Specify Device
EOF
exit 0
}

while getopts "d:t:Hh" OPT; do
  case ${OPT} in
    d) D="${OPTARG}";;
    t) T="${OPTARG}";;
    H) HEAD=1;;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

if [ "${HEAD}" ]; then
  df | \
  awk -v OFS="${D:-\t}" '
    NR==1 { print "Time", $2, $3, $4, $5 }
  '
  exit 0
fi

MNT=$1
test ${#MNT} -eq 0 && usage

ret=(`df ${MNT} | awk 'NR>=2 {print}'`)
test ${#ret} -eq 0 && exit 0
echo ${ret[@]} | \
  awk -v OFS="${D:-\t}" -v TIME="${T:-`date +%H:%M:%S`}" '
    { print TIME, $2, $3, $4, $5 }
  '

exit 0
