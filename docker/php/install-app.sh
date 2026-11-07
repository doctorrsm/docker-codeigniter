#!/bin/sh
# Installs CodeIgniter only when /var/www/html does not have it yet.
set -eu

cd /var/www/html
export HOME="${HOME:-/tmp}"
export COMPOSER_HOME="${COMPOSER_HOME:-/tmp/composer}"
mkdir -p "$COMPOSER_HOME"

if [ ! -f spark ]; then
  echo "Installing CodeIgniter appstarter..."
  tmp="$(mktemp -d)"
  composer create-project codeigniter4/appstarter "$tmp" --no-interaction --prefer-dist
  find "$tmp" -mindepth 1 -maxdepth 1 -exec cp -a {} /var/www/html/ \;
  rm -rf "$tmp"
  echo "CodeIgniter installed."
elif [ ! -f vendor/autoload.php ]; then
  echo "Installing Composer dependencies..."
  composer install --no-interaction --prefer-dist
  echo "Dependencies installed."
else
  echo "CodeIgniter is already installed."
fi
