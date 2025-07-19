# NASAPuff Ansible Deployment

This Ansible configuration provides a complete deployment solution for the NASAPuff Flask application, a NASA APOD (Astronomy Picture of the Day) viewer.

## Features

- **Production-ready Flask application** with improved error handling and logging
- **Gunicorn WSGI server** for better performance and stability
- **Nginx reverse proxy** with SSL/TLS support
- **Let's Encrypt SSL certificates** with automatic renewal
- **Systemd service management** with proper security settings
- **Comprehensive monitoring** with health checks and automated backups
- **Security hardening** with UFW firewall and fail2ban
- **Log rotation** and management
- **Automated deployment** with zero-downtime updates

## Prerequisites

- Ubuntu 20.04+ or Debian 11+
- Ansible 2.9+
- SSH access to target server
- Domain name pointing to the server

## Quick Start

1. **Clone the repository and navigate to the ansible directory:**
   ```bash
   cd ansible
   ```

2. **Update the inventory file** (`inventory.yml`) with your server details:
   ```yaml
   nasapuff-web:
     ansible_host: YOUR_SERVER_IP
     ansible_user: root
     ansible_ssh_private_key_file: ~/.ssh/id_rsa
   ```

3. **Update variables** in `group_vars/all.yml`:
   - Set your domain name
   - Update SSL email address
   - Modify NASA API key if needed

4. **Run the deployment:**
   ```bash
   ansible-playbook -i inventory.yml playbook.yml
   ```

## Configuration

### Variables

Key variables can be modified in `group_vars/all.yml`:

- `nasapuff_domain`: Your domain name
- `nasapuff_ssl_email`: Email for Let's Encrypt certificates
- `nasapuff_app_port`: Application port (default: 48080)
- `nasapuff_app_user`: Application user (default: nasapuff)

### Application Structure

```
/var/bertain-cdn/nasapuff/
├── flask/
│   ├── nasapuff_flask.py      # Main Flask application
│   ├── wsgi.py                # WSGI entry point
│   ├── requirements.txt       # Python dependencies
│   ├── templates/
│   │   ├── index.html        # Main page template
│   │   └── error.html        # Error page template
│   └── public/
│       └── css/
│           └── main.css      # Stylesheets
├── .env                      # Environment variables
├── run_nasapuff.sh          # Startup script
├── monitor-nasapuff.sh      # Monitoring script
├── health-check.sh          # Health check script
└── backup-nasapuff.sh       # Backup script
```

## Services

### Systemd Service

The application runs as a systemd service (`nasapuff-web`) with:
- Automatic restarts on failure
- Security hardening
- Proper logging
- Resource limits

### Nginx Configuration

- Reverse proxy to Flask application
- SSL/TLS termination
- Security headers
- Static file serving
- Health check endpoint

### Monitoring

- **Health checks** every 5 minutes
- **Daily backups** at 3 AM
- **Log rotation** and management
- **Resource monitoring** (disk, memory)

## API Endpoints

- `/` - Main application page
- `/health` - Health check endpoint
- `/api/apod` - NASA APOD data API

## Security Features

- **UFW firewall** with minimal open ports
- **fail2ban** for intrusion prevention
- **Security headers** in Nginx
- **Non-root user** for application
- **Systemd security settings**
- **SSL/TLS encryption**

## Maintenance

### Manual Health Check
```bash
sudo -u nasapuff /var/bertain-cdn/nasapuff/health-check.sh
```

### View Logs
```bash
# Application logs
tail -f /var/log/nasapuff/app.log

# Nginx logs
tail -f /var/log/nginx/nasapuff_access.log

# Systemd service logs
journalctl -u nasapuff-web -f
```

### Backup Management
```bash
# Manual backup
sudo -u nasapuff /var/bertain-cdn/nasapuff/backup-nasapuff.sh

# List backups
ls -la /var/backups/nasapuff/
```

### SSL Certificate Renewal
```bash
# Manual renewal
certbot renew

# Check certificate status
certbot certificates
```

## Troubleshooting

### Common Issues

1. **Service won't start:**
   ```bash
   systemctl status nasapuff-web
   journalctl -u nasapuff-web -n 50
   ```

2. **Nginx configuration errors:**
   ```bash
   nginx -t
   systemctl status nginx
   ```

3. **SSL certificate issues:**
   ```bash
   certbot certificates
   certbot renew --dry-run
   ```

4. **Permission issues:**
   ```bash
   ls -la /var/bertain-cdn/nasapuff/
   chown -R nasapuff:nasapuff /var/bertain-cdn/nasapuff/
   ```

### Performance Tuning

- Adjust Gunicorn workers based on CPU cores
- Modify Nginx buffer sizes for high traffic
- Configure log rotation for disk space management

## Updates

To update the application:

1. **Modify the Flask application** in `roles/nasapuff_app/templates/`
2. **Run the playbook** to deploy changes:
   ```bash
   ansible-playbook -i inventory.yml playbook.yml
   ```

The deployment includes zero-downtime updates with proper service management.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## License

This project is licensed under the MIT License. 