#!/bin/sh

# Create assets directory if it doesn't exist
mkdir -p /usr/share/nginx/html/assets

# Replace placeholders in assets/.env with runtime environment variables
cat <<EOF > /usr/share/nginx/html/assets/.env
SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}
EOF

# Start nginx
exec nginx -g 'daemon off;'
