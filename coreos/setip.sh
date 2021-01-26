sudo nmcli connection mod 'Wired connection 1' \
  ipv4.method manual \
  ipv4.addresses 192.168.20.10/24 \
  ipv4.gateway 192.168.20.254 \
  ipv4.dns 192.168.20.254 \
  +ipv4.dns 8.8.8.8 \
  connection.autoconnect yes
