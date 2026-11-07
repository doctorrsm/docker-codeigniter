#!/bin/sh
# Runs php-fpm as the developer's uid/gid so files in ./src stay theirs.
set -eu

uid="${HOST_UID:-1000}"
gid="${HOST_GID:-1000}"

# Moves a name:x:OLD: entry when OLD is already used by another name.
move_id() {
  file="$1"
  name="$2"
  old="$3"
  field="$4"

  free="$old"
  while awk -F: -v id="$free" -v field="$field" '($field == id) { found = 1 } END { exit !found }' "$file"; do
    free=$((free + 1))
  done

  if [ "$field" -eq 3 ]; then
    sed -i "s/^${name}:x:${old}:/${name}:x:${free}:/" "$file"
  fi
}

if [ "$uid" != "0" ]; then
  if ! grep -q '^www-data:' /etc/group; then
    addgroup -g "$gid" -S www-data
  else
    owner="$(awk -F: -v id="$gid" '$3 == id { print $1; exit }' /etc/group)"
    if [ -n "$owner" ] && [ "$owner" != "www-data" ]; then
      move_id /etc/group "$owner" "$gid" 3
    fi
    sed -i "s/^www-data:x:[0-9][0-9]*:/www-data:x:${gid}:/" /etc/group
  fi

  if ! grep -q '^www-data:' /etc/passwd; then
    adduser -u "$uid" -G www-data -S -D -H www-data
  else
    owner="$(awk -F: -v id="$uid" '$3 == id { print $1; exit }' /etc/passwd)"
    if [ -n "$owner" ] && [ "$owner" != "www-data" ]; then
      move_id /etc/passwd "$owner" "$uid" 3
    fi
    sed -i "s/^www-data:x:[0-9][0-9]*:[0-9][0-9]*:/www-data:x:${uid}:${gid}:/" /etc/passwd
  fi
fi

writable="/var/www/html/writable"
if [ -d "$writable" ]; then
  mkdir -p \
    "$writable/cache" \
    "$writable/logs" \
    "$writable/session" \
    "$writable/uploads" \
    "$writable/debugbar"
  chown -R "${uid}:${gid}" "$writable"
  find "$writable" -type d -exec chmod 775 {} +
  find "$writable" -type f -exec chmod 664 {} +
fi

exec docker-php-entrypoint "$@"
