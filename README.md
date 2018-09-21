Smalte
======

Smalte -- is a **smal**l **t**emplate **e**ngine. Specially designed
for configure application before start in Docker. This is best replacement for envsubset.

## Usage

```bash
$ export NGINX_WEBROOT /srv/www
$ smalte build --scope NGINX\.* \
    nginx1.conf.tmpl:nginx1.conf \
    nginx2.conf.tmpl:nginx2.conf
```

Will be replaced only env variables started with `NGINX\.*`.
Other values (like $url in Nginx config) will be skipped.
Also if $url not defined and Smalte using in global mode $url also will be skipped.

Examples can be found in the tests folder.

## Docker

Available Docker images for Ubuntu 18.04 and Alpine 3.8

## Version

```bash
$ smalte --version
```

## Help

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
