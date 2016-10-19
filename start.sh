NETWORKDEVICE=wlp2s0

echo "Enabling forwarding..."
sysctl net.ipv4.ip_forward=1
# For physical hosts with a wireless device
iptables -t nat -A POSTROUTING -o $NETWORKDEVICE -j MASQUERADE

echo "Disabling forwarding..."
sysctl net.ipv4.ip_forward=0
