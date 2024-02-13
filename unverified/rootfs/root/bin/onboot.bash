#!/bin/bash

for ((i=0;i<$(nproc);++i)) ; do
 cpufreq-set --cpu $i --max 1KHz
done

for ((i=0;i<$(nproc);++i)) ; do
 cpufreq-set --cpu $i --freq 1KHz
done


for iptables in iptables ip6tables ; do
 $iptables -P INPUT    DROP
 $iptables -P FORWARD  DROP
 $iptables -P OUTPUT   ACCEPT
 
 for table in nat filter mangle ; do
  $iptables -t $table -F
  $iptables -t $table -X
  $iptables -t $table -F
  $iptables -t $table -X
 done
done

iptables -A OUTPUT --destination 192.168.1.1 --protocol tcp --destination-port 53 --jump ACCEPT
iptables -A OUTPUT --protocol tcp --destination-port 53 --jump ACCEPT
iptables -A OUTPUT --protocol udp --destination-port 53 --jump ACCEPT
iptables -A OUTPUT --destination 192.168.1.0/24 -j DROP

iptables -A OUTPUT -p icmp -j DROP
iptables -A INPUT  -p icmp -j DROP

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

