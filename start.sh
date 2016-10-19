NETWORKDEVICE=wlp2s0
BRIDGBR0

echo "Enabling forwarding..."
sysctl net.ipv4.ip_forward=1
# For physical hosts with a wireless device
iptables -t nat -A POSTROUTING -o $NETWORKDEVICE -j MASQUERADE

echo "Setting up bridge..."
brctl addbr br0
ifconfig br0 10.0.0.1 


echo "Tearing down bridge..."
ifconfig br0 down
brctl delbr br0

echo "Disabling forwarding..."
sysctl net.ipv4.ip_forward=0
