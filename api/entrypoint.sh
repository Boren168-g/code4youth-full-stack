#!/bin/sh

# Exit on error
set -e

# Clear caches (ignore errors if paths don't exist yet)
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Run migrations
# --force is required for production
php artisan migrate --force

# Start Apache
apache2-foreground
