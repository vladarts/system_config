# cleanup
iptables -F
iptables -t nat -F

# srv3_forward
iptables -t nat -A POSTROUTING -s 10.8.2.0/24 -o eth0 -j MASQUERADE

# srv3_tor
iptables -t nat -A PREROUTING -i tun0 -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i tun0 -p tcp --syn -j REDIRECT --to-ports 9040