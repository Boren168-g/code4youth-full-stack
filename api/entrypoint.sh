#!/bin/sh

# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Ensure we have an .env file for the web server to read
if [ ! -f .env ]; then
    echo "Creating .env file from environment variables..."
    touch .env
fi

# Ensure APP_KEY is in the .env file so Apache can see it
if [ -n "$APP_KEY" ]; then
    echo "Using APP_KEY from environment variables."
    # Update or add APP_KEY in .env
    grep -q "APP_KEY=" .env && sed -i "s|APP_KEY=.*|APP_KEY=$APP_KEY|" .env || echo "APP_KEY=$APP_KEY" >> .env
else
    echo "Warning: APP_KEY is missing from environment. Generating a temporary one..."
    TEMP_KEY=$(php artisan key:generate --show --no-interaction)
    echo "APP_KEY=$TEMP_KEY" >> .env
    export APP_KEY=$TEMP_KEY
fi

# Force log to stderr so we can see errors in Render logs
grep -q "LOG_CHANNEL=" .env && sed -i "s|LOG_CHANNEL=.*|LOG_CHANNEL=stderr|" .env || echo "LOG_CHANNEL=stderr" >> .env

# Attempt to migrate.
echo "Running Database Migrations..."
php artisan migrate --force || echo "Migration failed. Check your database connection."

# Fix permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "Starting Apache Web Server on Port $PORT..."
# Start Apache
apache2-foreground
