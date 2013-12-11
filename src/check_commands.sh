#!/bin/bash
#===================================================================================
#
#         FILE: check_commands.sh
#
#        USAGE: check_commands.sh [-h] [-v]
#
#  DESCRIPTION: Check the required commands
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

  ${0} [-h] [-v]

    -v       : Verbose
    -h       : Get help

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Parameter check
#-------------------------------------------------------------------------------
while getopts "vh" OPT; do
  case ${OPT} in
    v) VERBOSE=1;;
    h|:|\?) usage;;
  esac
done

shift $(( $OPTIND - 1 ))

#-------------------------------------------------------------------------------
# Check commands
#-------------------------------------------------------------------------------
rt=0
test ${VERBOSE} && echo -e " \033[0;31mC\033[0;39mommand    : \033[0;31mP\033[0;39math"
cmd_path=$(which mpstat 2> /dev/null)
if [ $? -gt 0 ]; then
  echo "'mpstat' command not found"
  rt=1
fi
test ${VERBOSE} && echo "  mpstat    :  ${cmd_path}"

cmd_path=$(which iostat 2> /dev/null)
if [ $? -gt 0 ]; then
  echo "'iostat' command not found"
  rt=1
fi
test ${VERBOSE} && echo "  iostat    :  ${cmd_path}"

cmd_path=$(which df 2> /dev/null)
if [ $? -gt 0 ]; then
  echo "'df' command not found"
  rt=1
fi
test ${VERBOSE} && echo "  df        :  ${cmd_path}"

cmd_path=$(which vmstat 2> /dev/null)
if [ $? -gt 0 ]; then
  echo "'vmstat' command not found"
  rt=1
fi
test ${VERBOSE} && echo "  vmstat    :  ${cmd_path}"

cmd_path=$(which netstat 2> /dev/null)
if [ $? -gt 0 ]; then
  echo "'netstat' command not found"
  rt=1
fi
test ${VERBOSE} && echo "  netstat   :  ${cmd_path}"

exit ${rt}
