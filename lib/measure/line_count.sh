#!/bin/bash
#===================================================================================
#
#         FILE: line_count.sh
#
#        USAGE: line_count.sh [-d delimiter] [-D delay] [-T directory] [-H] [-h] condition
#
#  DESCRIPTION: count the number of rows that were in condition
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

  ${0} [-d delimiter] [-D delay] [-T directory] [-H] [-h] condition

    -d <arg>  : Result delimiter
                default : \\t
    -D <arg>  : Interval to aggregate
                default : 5 sec
    -T <arg>  : Temporary directory
                default : /var/tmp
    -H        : Return header only
    -h        : Get help
    condition : filename and grep keywords
                format  : filename:keyword[#keyword...]

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:D:T:Hh" OPT; do
  case ${OPT} in
    d) DELIMITER="${OPTARG}";;
    D) DELAY="${OPTARG}";;
    T) TMP_DIR="${OPTARG}";;
    H) HEAD=1;;
    h|:|\?) usage;;
  esac
done
shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Return the Header
#-------------------------------------------------------------------------------
if [ "${HEAD}" ]; then
  echo -en "Time${DELIMITER:-\t}"
  echo "${@}" | cut -d: -f2- | tr -s '#' '\n' | while read keyword
  do
    test ${m_col:-0} -gt 0 && echo -ne "${DELIMITER:-\t}"
    echo -ne "${keyword}"
    m_col=1
  done
  echo ""
  exit 0
fi

#-------------------------------------------------------------------------------
# Measure
#-------------------------------------------------------------------------------
TMP_DIR=${TMP_DIR:-/var/tmp}; test ! -d ${TMP_DIR} && mkdir -p ${TMP_DIR}
TMP_FILE=${TMP_DIR}/$$.${0##*/}
DELAY=${DELAY:-5}

filename=`echo "${@}" | cut -d: -f1`
test ! -f "${filename}" && exit 1

sleep ${DELAY} &
pid=$!
tail -n 0 --pid=${pid} -F ${filename} > ${TMP_FILE}

echo -ne "${now_time:-`date +%H:%M:%S`}${DELIMITER:-\t}"
echo "${@}" | cut -d: -f2- | tr -s '#' '\n' | while read keyword
do
  total=`grep "${keyword}" ${TMP_FILE} | wc -l`
  test ${m_col:-0} -gt 0 && echo -ne "${DELIMITER:-\t}"
  echo -ne `expr ${total} / ${DELAY}`
  m_col=1
done
echo ""

rm ${TMP_FILE}

exit 0
