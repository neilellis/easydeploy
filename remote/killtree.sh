#!/bin/bash

kill_tree() {
    local _pid=$(pgrep -o $1)
    local _sig=${2:--TERM}
    kill -stop ${_pid} # needed to stop quickly forking parent from producing children between child killing and parent killing
    for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
        kill_tree ${_child} ${_sig}
    done
    kill -${_sig} ${_pid}
}

if [ $# -eq 0 -o $# -gt 2 ]; then
    echo "Usage: $(basename $0) <owner-process> [signal]"
    exit 1
fi

kill_tree $@