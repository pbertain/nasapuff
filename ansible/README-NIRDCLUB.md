# NASAPuff Nird Club Deployment

This guide provides instructions for deploying the NASAPuff Flask application to Nird Club hosts using Ansible.

## Prerequisites

### 1. SSH Access Setup
Ensure you have SSH access to Nird Club hosts:

```bash
# Check if your SSH key exists
ls -la ~/.ssh/keys/nirdclub__id_ed25519

# Set proper permissions
chmod 600 ~/.ssh/keys/nirdclub__id_ed25519

# Test SSH connectivity
ssh -i ~/.ssh/keys/nirdclub__id_ed25519 ansible@host77.nird.club
ssh -i ~/.ssh/keys/nirdclub__id_ed25519 ansible@host78.nird.club
```

### 2. Ansible Installation
```bash
# Install Ansible (Ubuntu/Debian)
sudo apt update
sudo apt install ansible

# Or using pip
pip install ansible
```

## Quick Deployment

### 1. Clone the Repository
```bash
git clone https://github.com/pbertain/nasapuff.git
cd nasapuff/ansible
```

### 2. Verify Configuration
```bash
# Check deployment configuration
./deploy.sh info

# Validate SSH access
./deploy.sh validate
```

### 3. Deploy to Nird Club
```bash
# Run full deployment
./deploy.sh deploy
```

## Configuration Files

### `inventory.yml`
Defines the target hosts:
- `host77.nird.club`
- `host78.nird.club`

### `deployment.yml`
Contains deployment variables:
- SSH key path
- NASA API credentials
- Domain configuration
- Application settings

### `group_vars/all.yml`
Global variables for all hosts:
- System packages
- Python dependencies
- Nginx configuration

## Deployment Process

The deployment will:

1. **System Setup**
   - Install required packages
   - Create application user (`nasapuff`)
   - Set up log rotation

2. **Application Deployment**
   - Deploy Flask application
   - Create Python virtual environment
   - Install dependencies
   - Configure systemd service

3. **Web Server Configuration**
   - Install and configure Nginx
   - Configure reverse proxy
   - Set up security headers

4. **Monitoring Setup**
   - Install monitoring scripts
   - Configure log rotation
   - Set up automated backups

## Post-Deployment Verification

### 1. Check Service Status
```bash
# On each host
systemctl status nasapuff-web
systemctl status nginx
```

### 2. Test Application
```bash
# Health check
curl http://localhost:48080/health

# Main application
curl http://localhost:48080/

# API endpoint
curl http://localhost:48080/api/apod
```

## Monitoring and Maintenance

### Health Checks
```bash
# Manual health check
sudo -u nasapuff /var/bertain-cdn/nasapuff/health-check.sh

# View monitoring logs
tail -f /var/log/nasapuff/monitoring/monitor.log
```

### Logs
```bash
# Application logs
tail -f /var/log/nasapuff/app.log

# Nginx logs
tail -f /var/log/nginx/nasapuff_access.log
tail -f /var/log/nginx/nasapuff_error.log

# Systemd service logs
journalctl -u nasapuff-web -f
```

### Backups
```bash
# Manual backup
sudo -u nasapuff /var/bertain-cdn/nasapuff/backup-nasapuff.sh

# List backups
ls -la /var/backups/nasapuff/
```

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Check SSH key permissions
   chmod 600 ~/.ssh/keys/nirdclub__id_ed25519
   
   # Test SSH manually
   ssh -i ~/.ssh/keys/nirdclub__id_ed25519 ansible@host77.nird.club
   ```

2. **Service Won't Start**
   ```bash
   # Check service status
   systemctl status nasapuff-web
   
   # View detailed logs
   journalctl -u nasapuff-web -n 50
   
   # Check permissions
   ls -la /var/bertain-cdn/nasapuff/
   ```

3. **Permission Issues**
   ```bash
   # Fix ownership
   sudo chown -R nasapuff:nasapuff /var/bertain-cdn/nasapuff/
   sudo chown -R nasapuff:nasapuff /var/log/nasapuff/
   ```

### Performance Tuning

1. **Gunicorn Workers**
   ```bash
   # Edit service file
   sudo nano /etc/systemd/system/nasapuff-web.service
   
   # Adjust workers based on CPU cores
   --workers 4  # For 4+ CPU cores
   ```

2. **Nginx Optimization**
   ```bash
   # Edit nginx configuration
   sudo nano /etc/nginx/sites-available/nasapuff
   
   # Adjust buffer sizes for high traffic
   proxy_buffer_size 8k;
   proxy_buffers 16 8k;
   ```

## Security Considerations

### Application Security
- Non-root user execution
- Process isolation with systemd
- Security headers in Nginx
- Input validation and sanitization

### SSL/TLS Security
- SSL certificates handled by separate playbook
- Modern cipher suites configured
- HSTS headers enabled
- OCSP stapling configured

## Updates and Maintenance

### Application Updates
```bash
# Pull latest changes
git pull origin main

# Re-deploy
./deploy.sh deploy
```

### System Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade

# Restart services if needed
sudo systemctl restart nasapuff-web
sudo systemctl restart nginx
```

### Monitoring Alerts
Set up monitoring for:
- Service status
- Disk space usage
- Memory usage
- Backup success/failure

## Support

For issues or questions:
1. Check the logs first
2. Review the troubleshooting section
3. Test SSH connectivity
4. Verify configuration files

The deployment is designed to be robust and self-healing, with comprehensive monitoring and automated maintenance tasks. 