FROM php:8.2-apache-bookworm

ARG BASE_URL=https://www.timetrex.com/direct_download
ARG FILENAME=TimeTrex_Community_Edition-manual-installer.zip
ARG URL=${BASE_URL}/${FILENAME}

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
    libpspell-dev \
    libc-client-dev \
    libkrb5-dev \
    libxslt1-dev \
    libldap2-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pgsql pspell gd gettext imap intl soap zip ldap \
    xml xsl mbstring bcmath
RUN ln -s "$(which php)" /usr/bin/php

# Download and place TimeTrex
RUN curl -s "$URL" | bsdtar -xf- -C /var/www/html/ && \
    bash -c 'shopt -s dotglob && \
    cp -r /var/www/html/TimeTrex_*/* /var/www/html/' && \
    shopt -s dotglob && \
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
