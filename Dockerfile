FROM node:10.19.0
MAINTAINER Jasper Kang <jasper@adroitcreations.com>

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
    gulp-cli \
    bower \
    gulp

RUN apt-get install -y yarn

# Install PHP 7 and its modules
RUN apt-get install -y \
    php7.4 \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-json \
    php7.4-xml \
    php7.4-zip \
    php7.4-bz2 \
    php7.4-sqlite3 \
    php7.4-mysql \
    php7.4-gd \
    php7.4-soap \
    php7.4-bcmath \
    php7.4-ldap \
    php7.4-readline \
    php7.4-xmlrpc

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chmod a+x /usr/local/bin/composer
RUN composer selfupdate

# Install pip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py

# Install AWS CLI
RUN pip install awscli --ignore-installed six

#RUN mkdir /root/tmp_composer
#RUN cd /root/tmp_composer
#RUN wget https://www.adroitcreations.com/build/composer.json
#RUN wget https://www.adroitcreations.com/build/package.json
#RUN wget https://www.adroitcreations.com/build/bower.json
#RUN composer install || true
#RUN npm install || true
#RUN bower install --allow-root || true

# Clean up temporary files
RUN apt-get clean || apt-get autoclean && apt-get --purge -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh
ADD id_rsa.private /root/.ssh/id_rsa
ADD id_rsa.private.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa
RUN echo '' >> /etc/ssh/ssh_config
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

# Show versions
RUN node -v
RUN npm -v
RUN php -v
RUN composer -V
RUN gulp -v
