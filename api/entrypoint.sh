#!/bin/sh

# Exit on error
set -e

# Clear caches
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Run migrations (This will run every time the container starts)
# --force is required for production
php artisan migrate --force

# Start Apache
apache2-foreground
