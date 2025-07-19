#!/bin/bash

# NASAPuff Ansible Deployment Script for Nird Club
# This script provides an easy way to deploy the NASAPuff application to Nird Club hosts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INVENTORY_FILE="inventory.yml"
PLAYBOOK_FILE="playbook.yml"
ANSIBLE_CONFIG="ansible.cfg"
DEPLOYMENT_CONFIG="deployment.yml"

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  NASAPuff Nird Club Deployment${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if Ansible is installed
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    # Check if inventory file exists
    if [ ! -f "$INVENTORY_FILE" ]; then
        print_error "Inventory file '$INVENTORY_FILE' not found."
        exit 1
    fi
    
    # Check if playbook file exists
    if [ ! -f "$PLAYBOOK_FILE" ]; then
        print_error "Playbook file '$PLAYBOOK_FILE' not found."
        exit 1
    fi
    
    # Check if deployment config exists
    if [ ! -f "$DEPLOYMENT_CONFIG" ]; then
        print_error "Deployment config '$DEPLOYMENT_CONFIG' not found."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

validate_ssh_access() {
    print_step "Validating SSH access to Nird Club hosts..."
    
    # Check SSH key exists
    SSH_KEY=$(grep "ansible_ssh_private_key_file" "$INVENTORY_FILE" | head -1 | sed 's/.*: //' | tr -d ' "')
    if [ ! -f "$SSH_KEY" ]; then
        print_error "SSH key not found: $SSH_KEY"
        print_error "Please ensure your Nird Club SSH key is available."
        exit 1
    fi
    
    # Check if ansible can connect to hosts
    if ! ansible all -m ping &> /dev/null; then
        print_error "Cannot connect to Nird Club hosts. Please check:"
        print_error "1. SSH key permissions (chmod 600 $SSH_KEY)"
        print_error "2. Network connectivity to host77.nird.club and host78.nird.club"
        print_error "3. Ansible user permissions on target hosts"
        exit 1
    fi
    
    print_success "SSH access validation passed"
}

show_deployment_info() {
    print_step "Deployment Configuration:"
    echo -e "${YELLOW}Target Hosts:${NC}"
    grep "ansible_host" "$INVENTORY_FILE" | sed 's/.*: //' | sed 's/^/  - /'
    echo -e "${YELLOW}Domain:${NC} $(grep 'nasapuff_domain:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')"
    echo -e "${YELLOW}Port:${NC} $(grep 'nasapuff_app_port:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')"
    echo -e "${YELLOW}User:${NC} $(grep 'ansible_user:' "$INVENTORY_FILE" | head -1 | sed 's/.*: //' | tr -d ' "')"
    echo ""
}

run_deployment() {
    print_step "Starting deployment to Nird Club hosts..."
    
    # Run the playbook with verbose output
    if ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK_FILE" -v; then
        print_success "Deployment completed successfully!"
    else
        print_error "Deployment failed!"
        exit 1
    fi
}

show_post_deployment_info() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}Nird Club Deployment Summary${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "${YELLOW}Application URL:${NC} https://$(grep 'nasapuff_domain:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')"
    echo -e "${YELLOW}Application Port:${NC} $(grep 'nasapuff_app_port:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')"
    echo -e "${YELLOW}Log Directory:${NC} /var/log/nasapuff"
    echo ""
    echo -e "${YELLOW}Useful Commands:${NC}"
    echo -e "  Check service status: systemctl status nasapuff-web"
    echo -e "  View application logs: tail -f /var/log/nasapuff/app.log"
    echo -e "  Health check: curl http://localhost:$(grep 'nasapuff_app_port:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')/health"
    echo -e "  Manual backup: sudo -u nasapuff /var/bertain-cdn/nasapuff/backup-nasapuff.sh"
    echo ""
    echo -e "${YELLOW}Nird Club Hosts:${NC}"
    grep "ansible_host" "$INVENTORY_FILE" | sed 's/.*: //' | sed 's/^/  - /'
    echo ""
}

# Main execution
main() {
    print_header
    
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            validate_ssh_access
            show_deployment_info
            run_deployment
            show_post_deployment_info
            ;;
        "check")
            check_prerequisites
            validate_ssh_access
            show_deployment_info
            print_success "All checks passed!"
            ;;
        "validate")
            validate_ssh_access
            ;;
        "info")
            show_deployment_info
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  deploy   - Run the full deployment to Nird Club (default)"
            echo "  check    - Check prerequisites and SSH access"
            echo "  validate - Validate SSH connectivity to hosts"
            echo "  info     - Show deployment configuration"
            echo "  help     - Show this help message"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 