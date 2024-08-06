#!/bin/sh

set -e

antora generate default-site.yml --stacktrace

exec "$@"