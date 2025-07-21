FROM alpine:3.22
LABEL maintainer "Mike Smith <grimbough@gmail.com>"
ENV TZ="Europe/Berlin"

RUN apk --no-cache add logrotate kubectl

COPY logrotate /etc/logrotate.d/nginx

RUN set -x ; \
  addgroup -g 101 -S nginx ; \
  adduser -u 101 -D -S -G nginx nginx && exit 0 ; exit 1
USER nginx