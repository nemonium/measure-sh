# coding: utf-8
#-------------------------------------------------------------------------------
#   Input file format :
#     <extension_measures>
#       <ps_aggregate>
#         <group title="<title>" user_defined="<aggr_user_defined>" format="<format>">
#           <column user_defined="<user_defined>" condition="<condition>" />
#           ...
#         </group>
#         ...
#       </ps_aggregate>
#     </extension_measures>
#
#   Output format :
#     ps_aggregate:<data_path>:<title>:<aggr_user_defined>[,<format>]:<user_defined>,<condition>[#<user_defined>,<condition>...]
#-------------------------------------------------------------------------------
import getopt
import sys
import os
from xml.dom import minidom

## Define
#
measure_map_format = "ps_aggregate:%s:%s:%s:%s"
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
elems = xdoc.getElementsByTagName("ps_aggregate")

if elems.length == 0:
  sys.exit()

for g in elems[0].getElementsByTagName("group"):
  title        = g.getAttribute("title")
  aggregate    = g.getAttribute("user_defined")
  if g.getAttribute("format"):
    aggregate  = "%s,%s" % (aggregate, g.getAttribute("format"))
  column       = ""
  initialized  = 0
  for c in g.getElementsByTagName("column"):
    if initialized > 0:
      column = column + "#"
    initialized = 1
    column = column + '%s,%s' % (c.getAttribute("user_defined"), c.getAttribute("condition"))
  data_path = "data/ps_aggregate.%s.csv" % (title)
  print measure_map_format % (data_path, title, aggregate, column)
