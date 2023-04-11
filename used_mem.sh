#!/bin/bash

# htop version, 305 or latest
htop_version="305"

# load values (meminfo)
# https://github.com/htop-dev/htop/blob/c878343784f23d7cb18ccec6aa034f01aee8069e/linux/LinuxProcessList.c
availableMem=$(cat /proc/meminfo | grep ^MemAvailable: | grep -Eo '[0-9]+')
#echo avail $availableMem
freeMem=$(cat /proc/meminfo | grep ^MemFree: | grep -Eo '[0-9]+')
#echo free $freeMem
totalMem=$(cat /proc/meminfo | grep ^MemTotal: | grep -Eo '[0-9]+')
#echo total $totalMem
cachedMem=$(cat /proc/meminfo | grep ^Cached: | grep -Eo '[0-9]+')
#echo cached $cachedMem
sreclaimableMem=$(cat /proc/meminfo | grep ^SReclaimable: | grep -Eo '[0-9]+')
#echo reclaim $sreclaimableMem
buffersMem=$(cat /proc/meminfo | grep ^Buffers: | grep -Eo '[0-9]+')
#echo buffers $buffersMem
sharedMem=$(cat /proc/meminfo | grep ^Shmem: | grep -Eo '[0-9]+')
#echo shared $sharedMem

# load values (zfs)
# https://github.com/htop-dev/htop/blob/c878343784f23d7cb18ccec6aa034f01aee8069e/linux/LinuxProcessList.c
zfs_size=$(awk '/^size/ { print sprintf("%i", $3 / 1024) }' < /proc/spl/kstat/zfs/arcstats)
zfs_min=$(awk '/^c_min/ { print sprintf("%i", $3 / 1024) }' < /proc/spl/kstat/zfs/arcstats)
#echo c_min $zfs_min
#echo zfs $zfs_size

if [ $htop_version = "latest" ]; then
	# calculate used ram according to current version of htop (can't validate this version)
	# meminfo
	# https://github.com/htop-dev/htop/blob/c878343784f23d7cb18ccec6aa034f01aee8069e/linux/LinuxProcessList.c
	usedDiff=$(($freeMem + $cachedMem + $sreclaimableMem + $buffersMem))
	#echo usedDiff $usedDiff
	if [ $totalMem -ge $usedDiff ]; then
		usedMem=$(($totalMem - $usedDiff))
	else
		usedMem=$(($totalMem - $freeMem))
	fi

	# zfs
	# https://github.com/htop-dev/htop/blob/c878343784f23d7cb18ccec6aa034f01aee8069e/linux/Platform.c
	if [ $zfs_size -gt $zfs_min ]; then
		usedMem=$(($usedMem - ($zfs_size - $zfs_min)))
	else
		usedMem=$usedMem
	fi
else
	# calculate according to htop version 3.0.5 (values are matching my installed htop version)
	# https://github.com/htop-dev/htop/blob/ce6d60e7def146c13d0b8bca4642e7401a0a8995/linux/LinuxProcessList.c
	usedMem=$(($totalMem - $freeMem))
	cachedMem=$(($cachedMem + $sreclaimableMem - $sharedMem))
	# https://github.com/htop-dev/htop/blob/ce6d60e7def146c13d0b8bca4642e7401a0a8995/linux/Platform.c
	usedMem=$(($usedMem - ($buffersMem + $cachedMem)))
	usedMem=$(($usedMem - $zfs_size))
fi



# generate output
#echo $(echo "scale=3; $usedMem / 1024 / 1024" | bc -l)GB
echo $(($usedMem /1024))
