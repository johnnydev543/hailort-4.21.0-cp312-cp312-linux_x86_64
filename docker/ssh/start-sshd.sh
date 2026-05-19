#!/bin/bash

# Generate host keys at runtime if missing
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi

# Reset Hailo PCIe device to clear stale VDMA handles
# This fixes "Can't mmap vdma handle" errors after container restart
HAILO_PCI_DEVICE="0000:02:00.0"
if [ -d "/sys/bus/pci/devices/${HAILO_PCI_DEVICE}" ]; then
  echo "Resetting Hailo PCIe device ${HAILO_PCI_DEVICE}..."
  echo 1 > /sys/bus/pci/devices/${HAILO_PCI_DEVICE}/remove 2>/dev/null
  sleep 1
  echo 1 > /sys/bus/pci/rescan 2>/dev/null
  sleep 1
  echo "Hailo PCIe device reset complete."
else
  echo "Warning: Hailo PCIe device ${HAILO_PCI_DEVICE} not found, skipping reset."
fi

# Start hailort_service
hailort_service &

# Create Python venv if it doesn't exist
if [ ! -d /root/venv ]; then
  echo "Creating Python venv at /root/venv ..."
  python3 -m venv /root/venv
  echo "Venv created. Activate with: source /root/venv/bin/activate"
fi

cat > /etc/profile.d/hailo-welcome.sh << 'EOF'
if [ -d /root/venv ]; then
  echo ""
  echo "  venv at /root/venv — source /root/venv/bin/activate"
  echo ""
fi
EOF

# Start SSH daemon in foreground
exec /usr/sbin/sshd -D