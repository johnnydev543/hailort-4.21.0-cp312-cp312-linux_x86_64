#!/bin/bash
# Generate host keys at runtime if missing (e.g. when volume overlays /etc/ssh)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi

# Create Python venv if it doesn't exist
if [ ! -d /root/venv ]; then
  echo "Creating Python 3.12 venv at /root/venv ..."
  python3.12 -m venv /root/venv
  echo "Venv created. Activate with: source /root/venv/bin/activate"
fi

echo ""
echo "========================================="
echo "  Hailo SSH Environment Ready"
echo "========================================="
echo "  Python venv : /root/venv"
echo "  Activate    : source /root/venv/bin/activate"
echo "  Requirements: pip install -r /root/requirements.txt"
echo "========================================="
echo ""

# Start SSH daemon in foreground
exec /usr/sbin/sshd -D