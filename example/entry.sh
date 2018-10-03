#!/usr/bin/env sh

export PORT=${PORT:=8080}
export NGINX_WEBROOT=${NGINX_WEBROOT:="/srv/www"}
export NGINX_CLIENT_HEADER_TIMEOUT=${NGINX_HEADER_TIMEOUT:="120s"}
export NGINX_CLIENT_BODY_TIMEOUT=${NGINX_BODY_TIMEOUT:="120s"}
export NGINX_MAX_BODY_SIZE=${NGINX_MAX_BODY_SIZE:="2G"}

# replace variables before start
smalte build --scope PORT --scope NGINX\.* \
    /etc/nginx/nginx_spa.conf.tmpl:/etc/nginx/conf.d/default.conf

# run nginx as main container process
nginx -g "daemon off;"
