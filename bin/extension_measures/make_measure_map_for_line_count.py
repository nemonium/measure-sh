# coding: utf-8
#-------------------------------------------------------------------------------
#   Input file format :
#     <extension_measures>
#       <line_count>
#         <group title="<title>" file_path="<file_path>">
#           <column condition="<condition>" />
#           ...
#         </group>
#         ...
#       </line_count>
#     </extension_measures>
#
#   Output format :
#     line_count:<data_path>:<title>:<file_path>:<condition>[#<condition>...]
#-------------------------------------------------------------------------------
import getopt
import sys
import os
from xml.dom import minidom

## Define
#
measure_map_format = "line_count:%s:%s:%s:%s"
config = ""

## Usage
#
usage = '''
Usage:

  %s [-h] -c config

    -c,--config   : extention measures config file (require)
    -h            : Get help

''' % (__file__)

## Commandline arguments
#
opts, args = getopt.getopt(sys.argv[1:], "c:h", ["config=", "help"])
for o, a in opts:
  if o in ("-c", "--config"):
    config = a
  elif o in ("-h", "--help"):
    print usage
    sys.exit()

if os.path.isfile(config) == False:
  print >> sys.stderr, 'config not found.'
  sys.exit()

## Parse XML
#
xdoc = minidom.parse(config)
elems = xdoc.getElementsByTagName("line_count")

if elems.length == 0:
  sys.exit()

for g in elems[0].getElementsByTagName("group"):
  title       = g.getAttribute("title")
  file_path   = g.getAttribute("file_path")
  column      = ""
  initialized = 0
  for c in g.getElementsByTagName("column"):
    if initialized > 0:
      column = column + "#"
    initialized = 1
    column = column + '%s' % (c.getAttribute("condition"))
  data_path = "data/line_count.%s.csv" % (title)
  print measure_map_format % (data_path, title, file_path, column)
