Smalte
======

[![CircleCI](https://circleci.com/gh/roquie/smalte.svg?style=svg)](https://circleci.com/gh/roquie/smalte)
[![GitHub tag](https://img.shields.io/github/tag/roquie/smalte.svg)](https://github.com/roquie/smalte)
[![GitHub](https://img.shields.io/github/license/roquie/smalte.svg)](https://github.com/roquie/smalte/blob/master/LICENSE)

Smalte – is a **smal**l **t**emplate **e**ngine. Dynamically configure applications that require static configuration in docker container. This is best replacement for envsubst. [Example of usage](https://github.com/roquie/docker-php-webapp/blob/master/conf/start.sh#L28).

Written in [nim-lang](https://nim-lang.org) and compiled to C. Fast. Binary size (197kb).

## TL;DR

Replaces env variables with values from global system scope:

```bash
smalte build /etc/nginx/nginx_spa.conf.tmpl:/etc/nginx/nginx_spa.conf
```

## Why?

If you using `envsubst` utility for dynamically configure the application, you have to go ugly compromises, [like this](https://stackoverflow.com/questions/24963705/is-there-an-escape-character-for-envsubst):

```nginx
# Example of nginx config template for envsubst.
server {
    listen       $PORT;
    server_name  localhost;
    root $NGINX_WEBROOT;

    client_header_timeout $NGINX_CLIENT_HEADER_TIMEOUT;
    client_body_timeout $NGINX_CLIENT_BODY_TIMEOUT;
    client_max_body_size $NGINX_MAX_BODY_SIZE;

    location / {
        try_files ${DOLLAR}uri ${DOLLAR}uri/ @rewrites;
    }

    location @rewrites {
        rewrite ^(.+)$ /index.html last;
    }

    location ~* \.(?:ico|css|js|gif|jpe?g|png)$ {
        # Some basic cache-control for static files to be sent to the browser
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   $NGINX_WEBROOT;
    }
}
```

Do you see ugly `${DOLLAR}` solution? It's not readable and just terrible. Also `envsubst` if not found any variable in the system scope, he replaces her with an empty string (if replace `${DOLLAR}uri` with `$uri` in this config and was run `envsubst` again, variable `$url` will be replaced to empty string). It is not comfortable.

To resolve this problem I was created this small template engine.

## Guide

This is a full guide includes work with docker image.

1. Create a new template file with environment variables which need to be replaced. How example, the same config on the top:

```nginx
server {
    listen       $PORT;
    server_name  localhost;
    root $NGINX_WEBROOT;

    client_header_timeout $NGINX_CLIENT_HEADER_TIMEOUT;
    client_body_timeout $NGINX_CLIENT_BODY_TIMEOUT;
    client_max_body_size $NGINX_MAX_BODY_SIZE;

    location / {
        try_files $uri $uri/ @rewrites;
    }

    location @rewrites {
        rewrite ^(.+)$ /index.html last;
    }

    location ~* \.(?:ico|css|js|gif|jpe?g|png)$ {
        # Some basic cache-control for static files to be sent to the browser
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   $NGINX_WEBROOT;
    }
}
```

[Real example.](https://github.com/roquie/docker-php-webapp/blob/master/conf/nginx/nginx.conf.tmpl)

2. Give the name to him and add `.tmpl` extension (extension not required, but this more readable), for example: `nginx_spa.conf.tmpl`

[Real example.](https://github.com/roquie/docker-php-webapp/blob/master/conf/nginx)

3. Create a new `entry.sh` the script, define default env variables and write command to replace theirs.

```bash
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
```

Before `:` symbol places path to the template file, after – to result of the build.
`--scope` option reduces the list of global env variables to the selected. Supports regular expressions.

[Real example](https://github.com/roquie/docker-php-webapp/blob/master/conf/start.sh)

4. Copy config template file and `smalte` binary to you Docker-image:

```Dockerfile
FROM nginx:mainline-alpine

ENV NGINX_WEBROOT /usr/share/nginx/html
ENV PORT 8080

COPY nginx_spa.conf.tmpl /etc/nginx/nginx_spa.conf.tmpl
# chmod +x ./entry.sh before copy paste to image.
COPY entry.sh /
COPY --from=roquie/smalte:latest-alpine /app/smalte /usr/local/bin/smalte

WORKDIR /usr/share/nginx/html

CMD ["/entry.sh"]
```

[Real example](https://github.com/roquie/docker-php-webapp/blob/master/Dockerfile#L47)

5. Build docker-image and run. Enjoy.

Files used in guide located in the example directory.
More examples can be found in the tests folder. Also, available Docker-image where using this helper:
https://github.com/roquie/docker-php-webapp

## Example how to overwrite env variable at run

Just pass defined variables to `-e` options of docker run command, like this:

```bash
docker run -it --rm -e PORT=3000 -p 9090:3000 roquie/docker-php-webapp:latest
```

By default, this container uses 8080 port for nginx. At startup, I replaced the port with a different value (`3000`) uses the `$PORT` environment variable.

Test it:
```bash
$ curl http://localhost:9090
$ Hello world
```

## Depends

* libpcre

## Docker

Available Docker images for Ubuntu 18.04 and Alpine 3.8

## CLI Help

```bash
> Smalte - is a dead simple and lightweight template engine.

  Example:
    ./smalte build --scope NGINX\.* --scope NPM \
                test.conf.tmpl:test.conf \
                test.conf.tmpl:test2.conf \
                test.conf.tmpl:testN.conf

  Usage:
    smalte build [--scope=<scope> ...] <inputfile:outputfile>...
    smalte (-h | --help)
    smalte (-v | --version)

  Options:

    -h --help      Show this screen.
    -v --version   Show version.
```

## Usage from a Docker container

```Dockerfile
FROM ubuntu:18.04
COPY --from=roquie/smalte:latest /app/smalte /usr/local/bin/smalte

CMD ["/usr/local/bin/smalte"]
```

## The MIT License (MIT)

Copyright (c)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
