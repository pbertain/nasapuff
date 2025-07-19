#!/bin/bash

# NASAPuff Ansible Deployment Script
# This script provides an easy way to deploy the NASAPuff application

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

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  NASAPuff Ansible Deployment${NC}"
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
    
    print_success "Prerequisites check passed"
}

validate_inventory() {
    print_step "Validating inventory..."
    
    # Check if ansible can connect to hosts
    if ! ansible all -m ping &> /dev/null; then
        print_error "Cannot connect to hosts. Please check your inventory configuration."
        exit 1
    fi
    
    print_success "Inventory validation passed"
}

run_deployment() {
    print_step "Starting deployment..."
    
    # Run the playbook
    if ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK_FILE"; then
        print_success "Deployment completed successfully!"
    else
        print_error "Deployment failed!"
        exit 1
    fi
}

show_post_deployment_info() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}Deployment Summary${NC}"
    echo -e "${BLUE}================================${NC}"
    echo -e "${YELLOW}Application URL:${NC} https://$(grep -A1 'nasapuff_domain:' group_vars/all.yml | tail -n1 | sed 's/.*: //' | tr -d ' "')"
    echo -e "${YELLOW}Application Port:${NC} $(grep 'nasapuff_app_port:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')"
    echo -e "${YELLOW}Log Directory:${NC} /var/log/nasapuff"
    echo ""
    echo -e "${YELLOW}Useful Commands:${NC}"
    echo -e "  Check service status: systemctl status nasapuff-web"
    echo -e "  View application logs: tail -f /var/log/nasapuff/app.log"
    echo -e "  Health check: curl http://localhost:$(grep 'nasapuff_app_port:' group_vars/all.yml | sed 's/.*: //' | tr -d ' "')/health"
    echo -e "  Manual backup: sudo -u nasapuff /var/bertain-cdn/nasapuff/backup-nasapuff.sh"
    echo ""
}

# Main execution
main() {
    print_header
    
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            validate_inventory
            run_deployment
            show_post_deployment_info
            ;;
        "check")
            check_prerequisites
            validate_inventory
            print_success "All checks passed!"
            ;;
        "validate")
            validate_inventory
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  deploy   - Run the full deployment (default)"
            echo "  check    - Check prerequisites and inventory"
            echo "  validate - Validate inventory connectivity"
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