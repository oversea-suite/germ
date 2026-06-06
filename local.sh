#!/bin/bash

# static reads
printf 'uptime_s:%s\n'      "$(awk '{print $1}' /proc/uptime)"
printf 'load_avg:%s\n'      "$(awk '{print $1}' /proc/loadavg)"
printf 'cpu_temp_c:%s\n'    "$(awk '{printf "%.1f", $1/1000}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 'N/A')"
printf 'ram_total_kb:%s\n'  "$(awk '/MemTotal/{print $2}' /proc/meminfo)"
printf 'ram_used_kb:%s\n'   "$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t-a}' /proc/meminfo)"
printf 'ram_avail_kb:%s\n'  "$(awk '/MemAvailable/{print $2}' /proc/meminfo)"
printf 'swap_total_kb:%s\n' "$(awk '/SwapTotal/{print $2}' /proc/meminfo)"
printf 'swap_used_kb:%s\n'  "$(awk '/SwapTotal/{t=$2} /SwapFree/{f=$2} END{print t-f}' /proc/meminfo)"
printf 'disk_total_kb:%s\n' "$(df -k / | awk 'NR==2{print $2}')"
printf 'disk_used_kb:%s\n'  "$(df -k / | awk 'NR==2{print $3}')"

disk=$(lsblk -d -o NAME | grep -v NAME | head -1)

# first reads
read cpu_tot1 cpu_idle1 < <(awk '/^cpu /{tot=$2+$3+$4+$5+$6+$7+$8; print tot, $5}' /proc/stat)
read r1 w1              < <(awk -v d="$disk" '$3==d{print $6,$10}' /proc/diskstats)
read rx1 tx1            < <(awk '$1!="lo:" && $1!~/Inter|face/{rx+=$2; tx+=$10} END{print rx, tx}' /proc/net/dev)

sleep 1

# second reads + delta output
read cpu_tot2 cpu_idle2 < <(awk '/^cpu /{tot=$2+$3+$4+$5+$6+$7+$8; print tot, $5}' /proc/stat)
read r2 w2              < <(awk -v d="$disk" '$3==d{print $6,$10}' /proc/diskstats)
read rx2 tx2            < <(awk '$1!="lo:" && $1!~/Inter|face/{rx+=$2; tx+=$10} END{print rx, tx}' /proc/net/dev)

printf 'cpu_pct:%.1f\n'       "$(awk "BEGIN{d=$((cpu_tot2-cpu_tot1)); i=$((cpu_idle2-cpu_idle1)); printf \"%.1f\", 100*(d-i)/d}")"
printf 'disk_read_kb_s:%s\n'  "$(( (r2-r1)/2 ))"
printf 'disk_write_kb_s:%s\n' "$(( (w2-w1)/2 ))"
printf 'net_rx_kb_s:%s\n'     "$(( (rx2-rx1)/1024 ))"
printf 'net_tx_kb_s:%s\n'     "$(( (tx2-tx1)/1024 ))"

ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {n=split($11,a,"/"); printf "proc_cpu_%d:%s:%.1f\n", NR-1, a[n], $3}'
ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {n=split($11,a,"/"); printf "proc_ram_%d:%s:%.1f\n", NR-1, a[n], $4}'
