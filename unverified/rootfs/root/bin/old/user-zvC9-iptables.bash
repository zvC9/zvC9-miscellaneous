#!/bin/bash


iptables -P FORWARD DROP

iptables -t nat -F
iptables -F
iptables -t nat -X
iptables -X

iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

#iptables -t filter -A FORWARD -i ovpn1 -o enp0s0 -j ACCEPT
#iptables -t nat -A POSTROUTING -s 10.1.1.1 -o enp0s0 -j MASQUERADE

#iptables -t filter -A FORWARD -i ovpn2 -o enp0s0 -j ACCEPT
#iptables -t nat -A POSTROUTING -s 10.1.2.1 -o enp0s0 -j MASQUERADE

#iptables -t nat -A PREROUTING -s 10.1.1.1 -d 10.1.1.0 -p tcp --dport 8081 -j DNAT --to-destination 192.168.0.1:80
#iptables -t nat -A PREROUTING -s 10.1.2.1 -d 10.1.2.0 -p tcp --dport 8081 -j DNAT --to-destination 192.168.0.1:80

