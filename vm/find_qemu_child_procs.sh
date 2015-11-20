PID=$(pgrep qemu)
ps -o pid,ppid -ax | awk "{ if ( $2 == $PID ) { print $1 }}"

