#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Force DB_CONNECTION to mysql
export DB_CONNECTION=mysql

# Sync all environment variables to the .env file so the web server can see them
echo "Syncing Render environment variables..."
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' > .env

# Verify if DB_URL was found (don't print the value for security)
if grep -q "DB_URL=" .env; then
    echo "SUCCESS: DB_URL found in environment."
else
    echo "ERROR: DB_URL NOT FOUND. Please check Render Environment settings."
fi

# Ensure permissions are correct
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
php artisan migrate --force || echo "Migration failed. This is expected if Aiven IP is not whitelisted or password is wrong."

echo "Starting Apache Web Server..."
exec apache2-foreground
