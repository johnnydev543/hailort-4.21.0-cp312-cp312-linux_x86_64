#!/bin/bash
# Generate host keys at runtime if missing
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
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

# Start SSH daemon in foreground
exec /usr/sbin/sshd -D