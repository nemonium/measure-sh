#!/bin/bash
#===================================================================================
#
#         FILE: line_count_condition.sh
#
#        USAGE: line_count_condition.sh [-d delimiter] [-D condition_delimiter] [-h] ini_path section
#
#  DESCRIPTION: Make measure_line_count.sh's condition
#
#               Output format : file:condition[#condition...]
#
#                 ex)
#                   Input  [dsn]
#                          file=/var/log/maillog
#                          condition=client=
#                          condition=dsn=2
#                          condition=dsn=4
#                          condition=dsn=5
#                   Output /var/log/maillog:client=#dsn=2#dsn=4#dsn=5
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

  ${0} [-d delimiter] [-D condition_delimiter] [-h] ini_path section

    -d       : File and conditions delimiter
    -D       : Conditions delimiter
    -h       : Get help
    ini_path : Ini config file path
    sectioin : Target section
EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "d:D:h" OPT; do
  case ${OPT} in
    d) delimiter=${OPTARG};;
    D) condition_delimiter=${OPTARG};;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

ini_path=$1
section=$2
delimiter=${delimiter:-:}
condition_delimiter=${condition_delimiter:-#}

test ! -f "${ini_path}" && exit 1
test ! "${section}" && exit 1

sh ${LIB_DIR}/utils/read_ini.sh "${ini_path}" "${section}" file 1 |
  tr '\r' ${delimiter} | tr '\n' ${delimiter}
conditions=(`sh ${LIB_DIR}/utils/read_ini.sh "${ini_path}" "${section}" condition`)
echo -n "$(IFS=${condition_delimiter}; echo "${conditions[*]}")"

exit 0
