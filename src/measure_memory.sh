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
  vmstat -s | \
    awk -v D="${D:-\t}" -v COL=`vmstat -s | wc -l` -v TIME="${T:-`date +%H:%M:%S`}" '
      BEGIN {
        printf "Time" D
      }
      NR!=COL {
        for ( i = 2; i < NF; i++ ) {
          printf "%s_", $i
        }
        printf $NF D
      }
      NR==COL {
        print $2
      }
    '
  exit 0
fi

vmstat -s | \
  awk -v D="${D:-\t}" -v COL=`vmstat -s | wc -l` -v TIME="${T:-`date +%H:%M:%S`}" '
    BEGIN {
      printf TIME D
    }
    NR!=COL {
      printf $1 D 
    }
    NR==COL {
      print $1
    }
  '

exit 0
