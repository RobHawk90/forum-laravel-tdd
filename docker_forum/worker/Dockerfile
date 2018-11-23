FROM php:7.1-fpm-jessie

LABEL maintainer="ipunkt Business Solutions <info@ipunkt.biz>" \
        version.image="v3.0" \
        version.php=$PHP_VERSION \
        description="A supervisor configured to run with laravel artisan queue:work or artisan horizon command"

# Set timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PYTHON_VERSION=2.7.14-r2
ENV PY_PIP_VERSION=9.0.1-r1
ENV SUPERVISOR_VERSION=3.3.3

ENV QUEUE_CONNECTION=redis
ENV QUEUE_NAME=default
ENV LARAVEL_HORIZON=false

# Install pdo if you want to use database queue
RUN apt-get update
RUN apt-get install -y vim postgresql-client postgresql-contrib libmcrypt-dev zlib1g-dev libpq-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev cron \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && apt-get clean \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql mbstring mcrypt -j$(nproc) gd zip json xml pcntl \
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Install supervisor
RUN apt-get install -y python-pip
RUN pip install supervisor==$SUPERVISOR_VERSION

# Define working directory
WORKDIR /etc/supervisor/conf.d

# Setup Cron
RUN crontab -l | { cat; echo "* * * * * php /var/www/application/artisan schedule:run >> /dev/null 2>&1"; } | crontab -

# Use local configuration
COPY config/laravel-worker.conf.tpl /etc/supervisor/conf.d/laravel-worker.conf.tpl
COPY config/laravel-horizon.conf.tpl /etc/supervisor/conf.d/laravel-horizon.conf.tpl

# Copy scripts
COPY config/init.sh /usr/local/bin/init.sh

VOLUME /var/www/application

# Run supervisor
ENTRYPOINT ["/bin/sh", "/usr/local/bin/init.sh"]
