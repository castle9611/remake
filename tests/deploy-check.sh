#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
bash -n deploy.sh
test -s deploy/web/index.html
test -d deploy/web/assets
if grep -Eq 'nodejs.org|github.com|pnpm install|npm install|build:web' deploy.sh; then
    echo 'Deployment must use prebuilt files without downloading build tools.' >&2
    exit 1
fi
bash deploy.sh --help | grep -q 'Usage:'
for port in 0 65536 -1 abc 08080 '8080;echo unsafe'; do
    if output=$(bash deploy.sh "$port" 2>&1); then
        echo "Invalid port accepted: $port" >&2
        exit 1
    fi
    [[ $output == *'Port must be between'* ]]
done
if bash deploy.sh 8080 extra >/dev/null 2>&1; then
    echo 'Unexpected extra argument accepted.' >&2
    exit 1
fi
echo 'Deployment argument and syntax checks passed.'
