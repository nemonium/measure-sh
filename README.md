# Description
Measure the performance of the local host.

# Dependencies command

- mpstat
- iostat
- df
- vmstat
- netstat

# Usage
    measure.sh [-o directory] [-i interval] [-t term] [-h] [-v] [-e]
    
        -o <arg> : Specify results directory
                   Default : '$(cd $(dirname $0);pwd)/result-`date +%Y%m%d%H%M%S`'
        -i <arg> : Specify interval (range 1 .. 60)
                   Default : 5
        -t <arg> : Specify measure term
        -e <arg> : End time.
                   See the d option of the date command for format.
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

# Note
1. After the script, Transfer measurement results to Local PC.
2. Open the measure.html of results on the browser.
