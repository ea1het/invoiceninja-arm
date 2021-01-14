# Choose your option below
# ----------------------------------------------
# FROM ea1het/invoiceninja-arm-base:4.5.29-armv6
FROM ea1het/invoiceninja-arm-base:4.5.29-armv7

LABEL maintainer="Jonathan Gonzalez <j@0x30.io>"

ENV RUN_DEPENDENCIES="openssl gnupg supervisor"

RUN apk update                                 \
    && apk add --no-cache $RUN_DEPENDENCIES    \
    && apk add --no-cache nginx                \
    && rm -f /etc/nginx/conf.d/*               \
    && rm -f /etc/nginx/nginx.conf             \
    && rm -rf /root/.cache                     \
    && rm -rf /var/cache/apk/*                 \
    && mkdir -p /var/log/nginx

COPY ./supervisord.conf /etc/supervisord.conf
COPY ./nginx/conf.d/ /etc/nginx/conf.d
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./bin/ /ninja/bin/
COPY ./crontab.txt /var/crontab.txt

RUN crontab /var/crontab.txt                   \
    && mkdir -p /var/log/ninja_cron            \
    && mkdir -p /var/log/supervisor            \
    && touch /var/log/ninja_cron/reminders.log \
    && touch /var/log/ninja_cron/invoices.log  \
    && chmod +x /ninja/bin/*

CMD ["/ninja/bin/start"]
