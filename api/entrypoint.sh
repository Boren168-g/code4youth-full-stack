#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Force fix the common typo from Render Environment
if [ -n "$DB_CONNECTTION" ]; then
    export DB_CONNECTION="$DB_CONNECTTION"
fi

# Ensure MySQL is the driver
export DB_CONNECTION="mysql"

# Sync Render environment variables to the .env file
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' > .env
echo "DB_CONNECTION=mysql" >> .env
echo "SESSION_DRIVER=cookie" >> .env
echo "LOG_CHANNEL=stderr" >> .env

# Ensure permissions are correct
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
# If this fails, it's usually the Aiven Password or IP Whitelist
php artisan migrate --force || echo "Migration failed. Verify your Aiven Password and IP Whitelist (0.0.0.0/0)."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
