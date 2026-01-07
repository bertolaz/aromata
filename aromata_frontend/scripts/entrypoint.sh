#!/bin/sh

# Create assets directory if it doesn't exist
mkdir -p /usr/share/nginx/html/assets

# Replace placeholders in assets/.env with runtime environment variables
echo SUPABASE_URL=${SUPABASE_URL:-} > /usr/share/nginx/html/assets/.env
echo SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-} >> /usr/share/nginx/html/assets/.env

# Start nginx
exec nginx -g 'daemon off;'
