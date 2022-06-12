FROM php:7.4-apache-bullseye
ARG URL=https://www.timetrex.com/direct_download/TimeTrex_Community_Edition-manual-installer.zip

# Install PHP extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libarchive-tools \
        libpq-dev \
        zlib1g-dev \
        libpng-dev \
        libicu-dev \
        libxml2-dev \
        libzip-dev \
    && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pgsql gd gettext intl soap zip bcmath
RUN ln -s "$(which php)" /usr/bin/php

# Download and place TimeTrex
RUN curl -s "$URL" | bsdtar -xf- -C /var/www/html/ && \
    cp -r /var/www/html/TimeTrex_*/* /var/www/html/ && \
    rm -rf /var/www/html/TimeTrex_* && \
    cp timetrex.ini.php-example_linux timetrex.ini.php

# Create directories
RUN mkdir -p /var/timetrex/storage && \
    mkdir -p /var/log/timetrex && \
    chgrp -R www-data /var/timetrex/ && \
    chmod 775 -R /var/timetrex && \
    chgrp www-data -R /var/log/timetrex/ && \
    chmod 775 -R /var/log/timetrex && \
    chgrp www-data -R /var/www/html/ && \
    chmod 775 -R /var/www/html/

# Add our own entrypoint
COPY docker-timetrex-entrypoint /usr/local/bin
ENTRYPOINT ["docker-timetrex-entrypoint"]
