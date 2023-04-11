# memory_usage_script
Reimplementation of htop memory usage calculation. It respects ZFS Arc cache as cache like htop.

It implements the algorithms of two htop versions. 3.0.5 and the latest main branch (2023-04-11).
For 3.0.5 I verified the results against my htop, for main i could not verify the results of the script.
Algorithm has to be selected by setting a variable in the script (there are no CLI switches for that)

The script outputs the used memory in MiB (2^20 Bytes)!

## example usage

I call if from HomeAssistant over SSH via "Command line Sensor" to create a card with the correct memory usage of my proxmox server.

<img src=https://user-images.githubusercontent.com/51326311/231288774-880c372a-84e2-4600-abec-48f13cf53146.jpg width=350px />
