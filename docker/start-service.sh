#!/bin/bash

SSH_ENABLED=false
if command -v sshd &>/dev/null; then
  SSH_ENABLED=true
fi

# Start SSH daemon if installed
if [ "$SSH_ENABLED" = "true" ]; then
  # Generate host keys at runtime if missing
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
  fi
  echo "SSH server is enabled."
else
  echo "SSH server is not installed. Skipping sshd startup."
fi

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

# Auto-detect Hailo PCIe devices
for dev in /sys/bus/pci/devices/*/driver; do
  if readlink "$dev" 2>/dev/null | grep -q hailo; then
    HAILO_PCI=$(echo "$dev" | cut -d/ -f6)
    echo "Hailo PCIe device detected: $HAILO_PCI"
  fi
done || echo "Warning: No Hailo PCIe device detected"

# Keep container running: if SSH is enabled, keep foreground with sshd;
# otherwise, keep alive with a sleep infinity
if [ "$SSH_ENABLED" = "true" ]; then
  exec /usr/sbin/sshd -D
else
  echo "No SSH daemon. Keeping container alive with sleep infinity..."
  exec sleep infinity
fi