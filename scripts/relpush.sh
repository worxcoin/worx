#!/usr/bin/env sh
set -x
ssh -o BatchMode=yes -o StrictHostKeyChecking=no worx@88.198.86.0 "uptime"
scp $1 worx@88.198.86.0:/var/www/files.worxcoin.io/htdocs/releases/

