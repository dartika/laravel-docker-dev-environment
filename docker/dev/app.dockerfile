FROM php:fpm-alpine

# install commonly used php extensions
RUN apk add --no-cache \
    freetype-dev libpng-dev libjpeg-turbo-dev freetype libpng libjpeg-turbo && \
    docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) &&  \
    docker-php-ext-install -j${NPROC} gd pdo pdo_mysql opcache zip &&  \
    apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV php_vars /usr/local/etc/php/conf.d/docker-vars.ini

# tweak php-fpm config
RUN echo "cgi.fix_pathinfo=0" > ${php_vars} && \
    echo "upload_max_filesize = 100M"  >> ${php_vars} && \
    echo "post_max_size = 100M"  >> ${php_vars} && \
    echo "variables_order = \"EGPCS\""  >> ${php_vars} && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 4/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        ${fpm_conf}

# crontab
RUN echo "* * * * *   php /var/www/artisan schedule:run >> /dev/null 2>&1" >> /etc/crontabs/root

# Set the timezone.
RUN apk add -U tzdata && cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime

CMD crond && php-fpm