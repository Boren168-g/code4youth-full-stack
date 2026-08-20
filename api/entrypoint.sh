#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Force certain production env vars
export LOG_CHANNEL=stderr
export SESSION_DRIVER=cookie
export DB_CONNECTION=mysql

# Sync all environment variables to the .env file
# We EXPLICITLY ignore DB_URL here to avoid interference
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' | grep -v 'DB_URL' > .env
echo "LOG_CHANNEL=stderr" >> .env
echo "SESSION_DRIVER=cookie" >> .env

# Print diagnostic info to logs (safe version)
echo "Configured DB_HOST: $DB_HOST"
echo "Configured DB_USER: $DB_USERNAME"

# Ensure permissions are correct
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
# Retry logic for DB connection
MAX_RETRIES=5
COUNT=0
while [ $COUNT -lt $MAX_RETRIES ]; do
    if php artisan migrate --force; then
        echo "Migrations successful!"
        break
    else
        COUNT=$((COUNT + 1))
        echo "Migration attempt $COUNT failed. Retrying in 5 seconds..."
        sleep 5
    fi
done

if [ $COUNT -eq $MAX_RETRIES ]; then
    echo "CRITICAL: All migration attempts failed. Check Aiven IP Whitelist and Password."
fi

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
