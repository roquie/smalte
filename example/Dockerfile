FROM nginx:mainline-alpine

ENV NGINX_WEBROOT /usr/share/nginx/html
ENV PORT 8080

COPY nginx_spa.conf.tmpl /etc/nginx/nginx_spa.conf.tmpl
# chmod +x ./entry.sh before copy paste to image.
COPY entry.sh /
COPY --from=roquie/smalte:latest-alpine /app/smalte /usr/local/bin/smalte

WORKDIR /usr/share/nginx/html

CMD ["/entry.sh"]
