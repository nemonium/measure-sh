#!/bin/bash
#===================================================================================
#
#         FILE: read_ini.sh
#
#        USAGE: read_ini.sh ini_path section param [single_result]
#
#  DESCRIPTION: Read ini file value
#
#===================================================================================

ini_path=$1
section=$2
param=$3

test ! -f "${ini_path}" && exit 1
test ! "${section}" && exit 1
test ! "${param}" && exit 1

s_section_pos=`egrep -n "^\[${section}\]$" ${ini_path} | cut -d: -f1`
test ! "${s_section_pos}" && exit 1

e_section_pos=`egrep -n "^\[.+\]$" ${ini_path} | awk -F: -v s=${s_section_pos} '$1>s{print $1}' | head -1`
e_section_pos=${e_section_pos:-$((`cat ${ini_path} | wc -l` + 1))}

section_len=$((${e_section_pos} - ${s_section_pos}))

tail -n +${s_section_pos} ${ini_path} | head -${section_len} | grep "^${param}=" | cut -d= -f2- | while read rt
do
  echo ${rt}
  test "${4:+1}" && exit 0
done

exit 0
