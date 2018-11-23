FROM php:7.1-fpm-jessie

WORKDIR /var/www

# Set timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y vim postgresql-client postgresql-contrib libmcrypt-dev zlib1g-dev libpq-dev libxml2-dev libpng-dev npm git xdot \
    && apt-get clean \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring mcrypt zip json xml pcntl \
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
    && cd /tmp \
    && git clone https://github.com/tideways/php-profiler-extension.git \
    && cd php-profiler-extension \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && docker-php-ext-enable tideways_xhprof \
    && rm -rf /tmp/php-profiler-extension \
    && cd /usr/src \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# NPM
RUN npm config set strict-ssl false \
    && npm cache clean -f \
    && npm install -g n \
    && n stable \
    && npm update -g npm
