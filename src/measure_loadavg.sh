#!/bin/bash

function usage() {
cat << EOF
Usage:

  ${0} [-d delimiter] [-t time] [-H] [-h]

    -d <arg> : Specify delimiter
    -t <arg> : Specify date and time to be displayed
    -H       : Return header only
    -h       : Get help

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
  echo -e "Time${D:-\t}1min${D:-\t}5min${D:-\t}15min"
  exit 0
fi

cat /proc/loadavg | \
  awk -v OFS="${D:-\t}" -v TIME="${T:-`date +%H:%M:%S`}" '
    { print TIME, $1, $2, $3 }
  '

exit 0
