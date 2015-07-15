# measure-sh
Measure the performance of the local host.

## Dependencies command

- mpstat
- iostat
- df
- vmstat
- netstat
- ifconfig

## Usage
    measure.sh [-o directory] [-i interval] [-t term] [-h] [-v] [-e]
               [-c extention_measure_config]
    
        -o <arg> : Specify results directory
                   Default : '$(cd $(dirname $0);pwd)/result-`date +%Y%m%d%H%M%S`'
        -i <arg> : Specify interval (range 1 .. 60)
                   Default : 5
        -t <arg> : Specify measure term
        -e <arg> : End time.
                   See the d option of the date command for format.
        -c <arg> : extention measures config file
                   Default : '$(cd $(dirname $0);pwd)/conf/extension_measures.xml'
        -v       : Verbose
        -h       : Get help

### For example

    sh measure-sh/src/measure.sh -v -o `hostname` -e 23:00
     # Results directory : <hostname>
     # Measure interval  : 5 sec
     # 
     # Processors        : 0 1
     # Interfaces        : eth0 lo
     # IO-devices        : vda
     # Mounted           : / /proc /sys /dev/pts /dev/shm /boot /var /proc/sys/fs/binfmt_misc /var/lib/nfs/rpc_pipefs
     # 
     # Start time        : Tue Oct 29 22:20:45 JST 2013
     # End time          : Tue Oct 29 23:00:00 JST 2013
     # Elapsed time      : Tue Oct 29 22:20:50 JST 2013 (5 sec)

## Configuration

### conf/measure.conf

- RESULT_DIR
- INTERVAL
- MEASURE_TERM
- END_TIME
- VERBOSE
- EXTENTION_MEASURES_XML

`argument > config > export > default`

### conf/extension_measures.xml

        <?xml version="1.0" encoding="UTF-8"?>
        <extension_measures>
          <fd_count>
            <!-- If you aggregate the number of sendmail file descriptor -->
            <group title="fd">
              <column user_defined="comm" condition="sendmail" />
            </group>
          </fd_count>
          <line_count>
            <!-- If you want to aggregate the results of dsn of maillog -->
            <group title="dsn" file_path="/var/log/maillog">
              <column condition="client=" />
              <column condition="dsn=2" />
              <column condition="dsn=4" />
              <column condition="dsn=5" />
            </group>
          </line_count>
          <ps_aggregate>
           <!-- If you aggregate memory of process -->
            <group title="mem" user_defined="pmem" format="%.1f">
              <column user_defined="comm" condition="httpd" />
              <column user_defined="comm" condition="bash" />
            </group>
          </ps_aggregate>
          <ps_count>
            <!-- If you aggregate the number of sendmail process -->
            <group title="ps">
              <column user_defined="comm" condition="sendmail" />
            </group>
          </ps_count>
        </extension_measures>

## Note
1. After the script, Transfer measurement results to Local PC.
2. Open the measure.html of results on the browser.

        result-...
        |-- data
        |   |-- ...csv
        |   `-- ...csv
        |-- javascripts
        |   `-- measure.js
        |-- measure.html <---- here
        |-- measure-map
        `-- stylesheets
            `-- measure.css
