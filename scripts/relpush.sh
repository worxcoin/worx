#!/usr/bin/env sh
set -x

scp $1 $REMOTE_USER@$REMOTE_HOST:$REMOTE_APP_DIR
