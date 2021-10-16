#!/usr/bin/env sh
echo "$0: Looking for shell scripts in /docker-entrypoint.d/..."
for f in $(/usr/bin/find /docker-entrypoint.d/ -type f -name "*.sh"); do
    echo "$0: Launching $f";
    "$f"
done

exec "$@"
