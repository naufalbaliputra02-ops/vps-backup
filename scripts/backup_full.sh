#!/bin/bash
# Comprehensive VPS Backup Script
# Created: 2026-06-06

BACKUP_DIR="/root/backup"
VPS_DATA="/root"
GITHUB_REPO="https://github.com/naufalbaliputra02-ops/vps-backup.git"

# Clean up and initialize backup repo
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"
git init
git config --global user.name 'naufalbaliputra02-ops'
git config --global user.email 'krisssakti027@gmail.com'
git remote add origin "$GITHUB_REPO"

# Create backup structure
mkdir -p configs scripts packages

# Backup important configs (NO SSH KEYS - GitHub blocks secrets)
echo "⚙️ Backing up configs..."
cp /etc/ssh/sshd_config configs/ 2>/dev/null || true
cp /etc/hosts configs/ 2>/dev/null || true
cp /etc/hostname configs/ 2>/dev/null || true
cp /etc/fstab configs/ 2>/dev/null || true

# Backup scripts
echo "📜 Backing up scripts..."
cp "$VPS_DATA/backup.sh" scripts/ 2>/dev/null || true
cp "$VPS_DATA/backup_full.sh" scripts/ 2>/dev/null || true
cp "$VPS_DATA/notify_expiration.sh" scripts/ 2>/dev/null || true

# Backup installed packages
echo "📦 Backing up package lists..."
dpkg --get-selections > packages/installed_packages.txt 2>/dev/null || true
pip3 list > packages/python_packages.txt 2>/dev/null || true
npm list -g --depth=0 > packages/node_packages.txt 2>/dev/null || true

# Backup crontab
echo "⏰ Backing up crontab..."
crontab -l > configs/crontab_backup.txt 2>/dev/null || true

# Create .gitignore to exclude sensitive files
cat > .gitignore << EOF
# Exclude sensitive files
ssh/
*.key
*.pem
*.p12
id_*
EOF

# Create backup manifest
cat > backup_manifest.md << EOF
# VPS Backup Manifest
- **Date:** $(date)
- **Hostname:** $(cat /etc/hostname)
- **OS:** $(cat /etc/os-release | head -2)
- **Uptime:** $(uptime)

## Contents:
- System configs (sshd, hosts, fstab)
- Backup scripts
- Installed packages (apt, pip, npm)
- Crontab

## Notes:
- VPS expires: 2026-06-12
- Backup location: GitHub (naufalbaliputra02-ops/vps-backup)
- Auto-backup: Daily at 2 AM
- SSH keys excluded (GitHub blocks secrets)
EOF

# Commit and push
git add -A
git commit -m "Backup $(date +%Y-%m-%d_%H-%M-%S)"
git push origin master --force 2>&1 || echo "⚠️ Push failed"

echo "✅ Full backup completed!"
