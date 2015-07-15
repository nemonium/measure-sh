# coding: utf-8
#-------------------------------------------------------------------------------
#   Input file format :
#     <extension_measures>
#       <fd_count>
#         <group title="<title>">
#           <column user_defined="<user_defined>" condition="<condition>" />
#           ...
#         </group>
#         ...
#       </fd_count>
#     </extension_measures>
#
#   Output format :
#     fd_count:<data_path>:<title>:<user_defined>,<condition>[#<user_defined>,<condition>...]
#-------------------------------------------------------------------------------
import getopt
import sys
import os
from xml.dom import minidom

## Define
#
measure_map_format = "fd_count:%s:%s:%s"
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
elems = xdoc.getElementsByTagName("fd_count")

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
  data_path = "data/fd_count.%s.csv" % (title)
  print measure_map_format % (data_path, title, column)
