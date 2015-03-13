# coding: utf-8
#-------------------------------------------------------------------------------
#   Input file format :
#     <extension_measures>
#       <ps_count>
#         <group title="<title>">
#           <column user_defined="<user_defined>" condition="<condition>" />
#           ...
#         </group>
#         ...
#       </ps_count>
#     </extension_measures>
#
#   Output format :
#     ps_count:<data_path>:<title>:<user_defined>,<condition>[#<user_defined>,<condition>...]
#-------------------------------------------------------------------------------
import getopt
import sys
import os
from xml.dom import minidom

## Define
#
measure_map_format = "ps_count:%s:%s:%s"

data_dir = "data"
config = "%s/../../conf/extension_measures.xml" % os.path.abspath(os.path.dirname(__file__))

## Usage
#
usage = '''
Usage:

  %s [-c config][-d data_dir][-h]

    -c,--config   : Config file (xml) path
                    default : %s
    -d,--data_dir : Result data direcotry
                    default : data
    -h            : Get help

''' % (__file__, config)

## Commandline arguments
#
opts, args = getopt.getopt(sys.argv[1:], "c:d:h", ["config=", "data_dir=", "help"])
for o, a in opts:
  if o in ("-c", "--config"):
    config = a
  elif o in ("-d", "--data_dir"):
    data_dir = a
  elif o in ("-h", "--help"):
    print usage
    sys.exit()

## Parse XML
#
xdoc = minidom.parse(config)
elems = xdoc.getElementsByTagName("ps_count")

if elems.length == 0:
  sys.exit()

for g in elems[0].getElementsByTagName("group"):
  title       = g.getAttribute("title")
  column      = ""
  initialized = 0
  for c in g.getElementsByTagName("column"):
    if initialized > 0:
      column = column + "#"
    initialized = 1
    column = column + '%s,%s' % (c.getAttribute("user_defined"), c.getAttribute("condition"))
  data_path = "%s/ps_count.%s.csv" % (data_dir, title)
  print measure_map_format % (data_path, title, column)