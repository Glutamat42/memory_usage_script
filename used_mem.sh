#!/bin/bash

# in kB
arc_reserve_mem=$((512 * 1024))

free_used_mem=$(free -b | awk '/^Mem/ { print sprintf("%i", $3 / 1000 ) }')
mem_total=$(cat /proc/meminfo | grep MemTotal | grep -Eo '[0-9]+')
mem_avail=$(cat /proc/meminfo | grep Avail | grep -Eo '[0-9]+')
arc_size=$(awk '/^size/ { print sprintf("%i", $3 / 1000) }' < /proc/spl/kstat/zfs/arcstats)

free_used_mem=$(($free_used_mem*1000/1024))
mem_total=$(($mem_total*1000/1024))
mem_avail=$(($mem_avail*1000/1024))
arc_size=$(($arc_size*1000/1024))

echo $mem_total
echo $mem_avail
echo $arc_size

used_mem=$(($mem_total - $mem_avail - $arc_size + $arc_reserve_mem))
used_mem2=$(($free_used_mem - $arc_size))

echo $((($used_mem - $arc_reserve_mem) / 1024 ))mB
echo $(($used_mem2/1024/1024)).$(($used_mem2 / 1024 %1024))GB
#echo $used_mem

echo ---------------

### htop calculations
# https://github.com/htop-dev/htop/blob/c878343784f23d7cb18ccec6aa034f01aee8069e/linux/LinuxProcessList.c
availableMem=$(cat /proc/meminfo | grep ^MemAvailable: | grep -Eo '[0-9]+')
echo avail $availableMem
freeMem=$(cat /proc/meminfo | grep ^MemFree: | grep -Eo '[0-9]+')
echo free $freeMem
totalMem=$(cat /proc/meminfo | grep ^MemTotal: | grep -Eo '[0-9]+')
echo total $totalMem
cachedMem=$(cat /proc/meminfo | grep ^Cached: | grep -Eo '[0-9]+')
echo cached $cachedMem
sreclaimableMem=$(cat /proc/meminfo | grep ^SReclaimable: | grep -Eo '[0-9]+')
echo reclaim $sreclaimableMem
buffersMem=$(cat /proc/meminfo | grep ^Buffers: | grep -Eo '[0-9]+')
echo buffers $buffersMem
sharedMem=$(cat /proc/meminfo | grep ^Shmem: | grep -Eo '[0-9]+')
echo shared $sharedMem

usedDiff=$(($freeMem + $cachedMem + $sreclaimableMem + $buffersMem))
echo usedDiff $usedDiff
#latest
#if [ $totalMem -ge $usedDiff ]; then
#usedMem=$(($totalMem - $usedDiff))
#else
#usedMem=$(($totalMem - $freeMem))
#fi

#3.0.5
usedMem=$(($totalMem - $freeMem))
usedMem=$(($usedMem - $buffersMem - ($cachedMem + $sreclaimableMem - $sharedMem)))
echo used $usedMem


# https://github.com/htop-dev/htop/blob/c878343784f23d7cb18ccec6aa034f01aee8069e/linux/LinuxProcessList.c
zfs_size=$(awk '/^size/ { print sprintf("%i", $3 / 1024) }' < /proc/spl/kstat/zfs/arcstats)
zfs_min=$(awk '/^c_min/ { print sprintf("%i", $3 / 1024) }' < /proc/spl/kstat/zfs/arcstats)
echo c_min $zfs_min
echo zfs $zfs_size


# https://github.com/htop-dev/htop/blob/e207c8aebdcdb88bc8ab838e2ac3dd1774d6a618/linux/Platform.c
#latest
#if [ $zfs_size -gt $zfs_min ]; then
#usedMem=$(($usedMem - ($zfs_size - $zfs_min)))
#else
#usedMem=$usedMem
#fi

#3.0.5
usedMem=$(($usedMem - $zfs_size))


final_used_gb=$(($usedMem/1024/1024))
final_used_mb=$(((($usedMem - $final_used_gb * 1024*1024)/1024)*1000/1024))
echo final used $final_used_gb GB $final_used_mb MB


# test
cachedMem=$(($cachedMem + ($zfs_size - $zfs_min)))
echo $(($cachedMem /1024/1024)).$(($cachedMem/1024%1024))GB
