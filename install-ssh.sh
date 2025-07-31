#!/usr/bin/env sh

# echo
echo_date() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

if ! launchctl print system/com.openssh.sshd &>/dev/null; then
  echo "→ Enabling SSH daemon..."
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
else
  echo "✅ SSH daemon already enabled"
fi
