#!/bin/bash

if [ -f /var/www/html/wp-includes/version.php ]; then
  LOCAL_VERSION=$(grep "wp_version =" /var/www/html/wp-includes/version.php | awk -F "'" '{print $2}')
else
  LOCAL_VERSION="none"
fi

echo "Local WordPress version: $LOCAL_VERSION"

NEW_VERSION=$(curl -s https://api.wordpress.org/core/version-check/1.7/ | jq -r '.offers[0].version')
echo "Latest WordPress version available: $NEW_VERSION"

if [ "$LOCAL_VERSION" = "none" ] || [ "$LOCAL_VERSION" != "$NEW_VERSION" ]; then
  echo "New version detected, updating WordPress..."
  wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz
  tar -xzf /tmp/latest.tar.gz -C /tmp
  tar -czf /tmp/wordpress_backup_$(date +%F).tar.gz -C /var/www/html .
  cp -r /tmp/wordpress/* /var/www/html/
  rm -rf /tmp/latest.tar.gz /tmp/wordpress
else
  echo "No changes detected, WordPress is up to date."
fi

if [ "$LOCAL_VERSION" = "none" ] || [ "$LOCAL_VERSION" != "$NEW_VERSION" ]; then
  exit 1 
else
  exit 0 
fi
#