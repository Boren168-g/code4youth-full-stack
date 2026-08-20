#!/bin/sh

# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Create the .env file and populate it with relevant environment variables from Render
# This ensures that both Artisan and the Web Server see the same configuration.
echo "Populating .env from environment..."
cat <<EOF > .env
APP_NAME=Code4Youth
APP_ENV=production
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-http://localhost}
APP_KEY=${APP_KEY}

DB_CONNECTION=${DB_CONNECTION:-mysql}
DB_URL=${DB_URL}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

LOG_CHANNEL=stderr
SESSION_DRIVER=cookie
CACHE_STORE=file
FILESYSTEM_DISK=local
EOF

# Ensure we have an APP_KEY if it wasn't provided
if [ -z "$APP_KEY" ]; then
    echo "Warning: APP_KEY is missing. Generating one..."
    php artisan key:generate --force --no-interaction
fi

# Ensure all required directories exist and are writable
echo "Setting up directories and permissions..."
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Clear and pre-cache to avoid runtime disk write issues
echo "Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
# We skip view:cache if it causes issues, but we ensure the path exists
mkdir -p storage/framework/views

# Attempt to migrate
echo "Running Database Migrations..."
php artisan migrate --force || echo "Migration failed. Check your DB_URL and Aiven IP Whitelist (0.0.0.0/0)."

echo "Starting Apache Web Server on Port $PORT..."
# Start Apache
exec apache2-foreground
