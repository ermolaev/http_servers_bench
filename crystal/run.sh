#!/bin/bash

cat /sys/fs/cgroup/cpu.max
cpu_limit_info=$(cat /sys/fs/cgroup/cpu.max)
quota=$(echo $cpu_limit_info | awk '{print $1}')
period=$(echo $cpu_limit_info | awk '{print $2}')

if [ "$quota" == "max" ]; then
  echo "CPU limit: unlimited"
  for i in $(seq 1 $(nproc --all)); do
    ./server &
  done
else
  cpu_limit=$(($quota / $period))

  echo "CPU limit: $cpu_limit core(s)"
  for i in $(seq 1 $cpu_limit); do
    ./server &
  done
fi

wait