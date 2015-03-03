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

#===  FUNCTION  ================================================================
#         NAME: which_cmd
#  DESCRIPTION: Check for the existence of a command.
#===============================================================================
function which_cmd() {
  cmd=$1
  local rt
  local message
  cmd_path=$(which ${cmd} 2> /dev/null)
  if [ $? -gt 0 ]; then
    message="\`${cmd}\` command not found"
    rt=1
  fi
  if [ ${VERBOSE:-0} -gt 0 ]; then
    printf "  %-10s:  %s\n" "${cmd}" "${cmd_path:-${message}}"
  else
    test ${#message} -gt 0 && echo ${message} >&2
  fi
  return ${rt:-0}
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

which_cmd mpstat;  test $? -gt 0 && rt=1
which_cmd iostat;  test $? -gt 0 && rt=1
which_cmd df;      test $? -gt 0 && rt=1
which_cmd vmstat;  test $? -gt 0 && rt=1
which_cmd netstat; test $? -gt 0 && rt=1

exit ${rt:-0}
