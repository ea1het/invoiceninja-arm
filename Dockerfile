# Choose your option below
# ----------------------------------------------
FROM ea1het/invoiceninja-arm-base:latest-armv6
# FROM ea1het/invoiceninja-arm-base:latest-armv7

LABEL maintainer="N/A"

ENV BUILD_DEPENDENCIES="wget"
ENV RUN_DEPENDENCIES="openssl gnupg supervisor cron net-tools htop"

RUN apt-get update -y                                                                                         \
    && apt-get install --no-install-recommends --no-install-suggests -y $BUILD_DEPENDENCIES $RUN_DEPENDENCIES \
    && apt-get install --no-install-recommends --no-install-suggests -y nginx                                 \
    && rm -f /etc/nginx/conf.d/*                                                                              \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPENDENCIES       \
    && apt-get clean                                                                                          \
    && mkdir -p /var/log/nginx                                                                                \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./supervisord.conf /etc/supervisord.conf 
COPY ./nginx/conf.d/ /etc/nginx/conf.d 
COPY ./bin/ /ninja/bin/
COPY ./crontab.txt /var/crontab.txt

RUN crontab /var/crontab.txt                           \
    && chmod 600 /etc/crontab                          \
    && mkdir -p /var/log/ninja_cron                    \
    && mkdir -p /var/log/supervisor                    \
    && touch /var/log/ninja_cron/reminders.log         \
    && touch /var/log/ninja_cron/invoices.log          \
    && chmod +x /ninja/bin/*

CMD ["/ninja/bin/start"]
