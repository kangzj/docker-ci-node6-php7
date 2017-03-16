FROM node:6.10.0
MAINTAINER Aaron Picht <apicht@users.noreply.github.com>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSER_NO_INTERACTION 1

# Tell npm to display only warnings and errors
ENV NPM_CONFIG_LOGLEVEL warn

# Install prerequsites
RUN apt-get update \
 && apt-get install -y apt-transport-https lsb-release ca-certificates

# Add repositories
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
 && wget -O- https://packages.sury.org/php/apt.gpg | apt-key add - \
 && wget -O- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && apt-get update \
 && apt-get upgrade -y

# Install essential tools
RUN apt-get install -y \
    git \
    zip \
    unzip \
    libfontconfig

# Install Python and its headers (used by node-gyp and awscli)
RUN apt-get install -y \
    python2.7 \
    python-dev

# Install Node tools
RUN npm install -g \
    node-gyp \
    gulp-cli
RUN apt-get install -y yarn

# Install PHP 7 and its modules
RUN apt-get install -y \
    php7.0 \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-curl \
    php7.0-json \
    php7.0-xml \
    php7.0-zip \
    php7.0-bz2 \
    php7.0-sqlite3 \
    php7.0-mysql \
    php7.0-gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chmod a+x /usr/local/bin/composer
RUN composer selfupdate

# Install pip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py

# Install AWS CLI
RUN pip install awscli --ignore-installed six

# Clean up temporary files
RUN apt-get clean && apt-get autoclean && apt-get --purge -y autoremove && \
    npm cache clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Show versions
RUN node -v
RUN npm -v
RUN php -v
RUN composer -V
