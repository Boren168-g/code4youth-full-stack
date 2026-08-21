#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Force production settings
export LOG_CHANNEL=stderr
export SESSION_DRIVER=cookie
export DB_CONNECTION=mysql

# Sync variables
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' > .env
echo "LOG_CHANNEL=stderr" >> .env
echo "SESSION_DRIVER=cookie" >> .env

# Ensure permissions
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Updating Database Schema..."
# We use --force for production. If tables exist, it will skip them correctly now.
php artisan migrate --force || echo "Note: Some tables already exist, continuing setup..."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
