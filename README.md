# measure-sh
Measure the performance of the local host.

## Dependencies command

- mpstat
- iostat
- df
- vmstat
- netstat

## Usage
    measure.sh [-o directory] [-i interval] [-t term] [-h] [-v] [-e]
               [-l path] [-p path] [-a path] [-f path]
    
        -o <arg> : Specify results directory
                   Default : '$(cd $(dirname $0);pwd)/result-`date +%Y%m%d%H%M%S`'
        -i <arg> : Specify interval (range 1 .. 60)
                   Default : 5
        -t <arg> : Specify measure term
        -e <arg> : End time.
                   See the d option of the date command for format.
        -l <arg> : line_count ini file path
                   Default : '$(cd $(dirname $0);pwd)/conf/measure_line_count.ini'
        -p <arg> : ps_count ini file path
                   Default : '$(cd $(dirname $0);pwd)/conf/measure_ps_count.ini'
        -a <arg> : ps_aggregate ini file path
                   Default : '$(cd $(dirname $0);pwd)/conf/measure_ps_aggregate.ini'
        -f <arg> : fd_count ini file path
                   Default : '$(cd $(dirname $0);pwd)/conf/measure_fd_count.ini'
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
- MAP_DELIMITER
- MEASURE_TERM
- END_TIME
- VERBOSE

`argument > config > export > default`

### conf/measure_line_count.ini

- ex) If you want to aggregate the results of dsn of maillog.

        [dsn]
        file=/var/log/maillog
        condition=client=
        condition=dsn=2
        condition=dsn=4
        condition=dsn=5

### conf/measure_ps_count.ini

- ex) If you aggregate the number of sendmail process.

        [process]
        condition=comm:sendmail

### conf/measure_ps_aggregate.ini

- ex) If you aggregate memory of process.

        [mem]
        aggregate=pmem:%.1f
        condition=comm:httpd
        condition=comm:bash

### conf/measure_fd_count.ini

- ex) If you aggregate the number of sendmail file descriptor.

        [process]
        condition=comm:sendmail

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
