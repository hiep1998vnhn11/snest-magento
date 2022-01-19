FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  unzip

RUN apt install -y libxslt-dev
RUN apt install -y libzip-dev
RUN apt install -y libjpeg-dev
RUN apt install -y libfreetype6-dev
RUN apt install -y zlib1g-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath intl soap sockets
RUN docker-php-ext-install xsl
RUN docker-php-ext-install zip
RUN docker-php-ext-configure gd --with-jpeg --with-freetype
RUN docker-php-ext-install -j$(nproc) gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
  chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user