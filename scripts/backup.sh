#!/bin/bash
# VPS Backup Script - Auto backup to GitHub
# Created: 2026-06-06

BACKUP_DIR=/root/backup
VPS_DATA=/root
GITHUB_REPO=git@github.com:nabapu13/vps-backup.git

# Initialize backup repo if not exists
if [ ! -d /.git ]; then
    mkdir -p 
    cd 
    git init
    git remote add origin 
fi

cd 

# Copy important files
echo 📦 Backing up files...
cp -r /.ssh . 2>/dev/null || true
cp -r /.bashrc . 2>/dev/null || true
cp -r /.profile . 2>/dev/null || true
cp -r /.gitconfig . 2>/dev/null || true

# Backup installed packages
dpkg --get-selections > installed_packages.txt 2>/dev/null || true
pip3 list > python_packages.txt 2>/dev/null || true
npm list -g --depth=0 > node_packages.txt 2>/dev/null || true

# Backup crontab
crontab -l > crontab_backup.txt 2>/dev/null || true

# Backup important configs
cp /etc/ssh/sshd_config . 2>/dev/null || true
cp /etc/hosts . 2>/dev/null || true
cp /etc/hostname . 2>/dev/null || true

# Create backup info
cat > backup_info.md << EOF
# VPS Backup Info
- **Date:** Sat Jun  6 13:00:48 +08 2026
- **Hostname:** localhost.localdomain
- **OS:** PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
- **Uptime:**  13:00:48 up 2 min,  0 users,  load average: 0.12, 0.07, 0.02

## Files Backed Up:
- SSH keys
- Bash config
- Git config
- Installed packages (apt, pip, npm)
- Crontab
- System configs
EOF

# Commit and push
git add -A
git commit -m Backup 2026-06-06_13-00-48
git push origin master --force 2>/dev/null || echo ⚠️ Push failed - need to add SSH key to GitHub

echo ✅ Backup completed!
