FROM php:7.4-apache

ENV DB_CONNECTION=mysql
ENV DB_HOST=mariadb
ENV DB_PORT=3306
ENV DB_DATABASE=vpnadmin
ENV DB_USERNAME=vpnadmin_user
ENV DB_PASSWORD=vpnadmin_pass

# Install tools required for build stage
RUN apt-get update \
 && apt-get install -fyqq \
    bash curl wget rsync ca-certificates openssl openssh-client git tzdata \
    libxrender1 fontconfig libc6 \
    gnupg binutils-gold autoconf \
    g++ gcc gnupg libgcc1 linux-headers-amd64 make python

# Install additional PHP libraries
RUN docker-php-ext-install \
    pcntl \
    bcmath

# Install mbstring plugin
RUN apt-get update \
 && apt-get install -fyqq libonig5 libonig-dev \
 && docker-php-ext-install mbstring \
 && apt-get remove -fyqq libonig-dev

# Add ZIP archives support (not needed here)
RUN apt-get update \
 && apt-get install -fyqq zip libzip-dev \
 && docker-php-ext-install zip \
 && apt-get remove -fyqq libzip-dev

# Install xdebug
RUN pecl install xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && chmod 755 /usr/bin/composer

# Add apache to run and configure
RUN a2enmod rewrite && a2enmod session && a2enmod session_cookie && a2enmod session_crypto && a2enmod deflate
ADD apache.conf /etc/apache2/sites-available/000-default.conf

RUN mkdir -pv /app \
 && chown -R www-data:www-data /app \
 && chmod -R 755 /app

WORKDIR /app
COPY . /app
RUN chown www-data:www-data . -R \
 && composer install --no-dev

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/app/entrypoint.sh"]
