
FROM php:8.3-apache

RUN docker-php-ext-install pdo pdo_mysql

RUN a2enmod rewrite && \
    sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

WORKDIR /var/www/html

EXPOSE 80
