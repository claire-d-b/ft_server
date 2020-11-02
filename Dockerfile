FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y nginx php php-fpm wget
RUN apt-get install -y php7.3-mysql
RUN apt-get -y install apt-utils

RUN unlink /etc/nginx/sites-enabled/default && mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default_old
COPY default_nginx /etc/nginx/sites-available/default
RUN rm -rf /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN cd /etc/nginx/ && mkdir ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out \
/etc/nginx/ssl/nginx.crt -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42/OU=clde-ber/CN=helloworld"

RUN cd /var/www/html/ && wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz \
&& tar -xvzf phpMyAdmin-5.0.2-english.tar.gz && mv phpMyAdmin-5.0.2-english phpmyadmin && rm phpMyAdmin-5.0.2-english.tar.gz
COPY config_php var/www/html/phpmyadmin/config.inc.php
RUN rm /etc/php/7.3/fpm/php.ini
COPY php.ini /etc/php/7.3/fpm/php.ini

RUN apt-get -y update && apt-get -y install libsasl2-2 libaio1 libmecab2 libnuma1 perl && cd /var/lib/ && wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-common_8.0.22-1debian10_amd64.deb && \
dpkg -i mysql-common_8.0.22-1debian10_amd64.deb && \ 
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-community-client-plugins_8.0.22-1debian10_amd64.deb && dpkg -i \
mysql-community-client-plugins_8.0.22-1debian10_amd64.deb && \
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/libmysqlclient21_8.0.22-1debian10_amd64.deb && dpkg -i libmysqlclient21_8.0.22-1debian10_amd64.deb && \ 
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/libmysqlclient-dev_8.0.22-1debian10_amd64.deb \
&& dpkg -i libmysqlclient-dev_8.0.22-1debian10_amd64.deb && \
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-community-client-core_8.0.22-1debian10_amd64.deb && \
dpkg -i mysql-community-client-core_8.0.22-1debian10_amd64.deb && \
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-community-client_8.0.22-1debian10_amd64.deb && \
dpkg -i mysql-community-client_8.0.22-1debian10_amd64.deb && \
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-client_8.0.22-1debian10_amd64.deb \
&& dpkg -i mysql-client_8.0.22-1debian10_amd64.deb && wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-community-server-core_8.0.22-1debian10_amd64.deb \
&& dpkg -i mysql-community-server-core_8.0.22-1debian10_amd64.deb && \
wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-community-server_8.0.22-1debian10_amd64.deb && \
dpkg -i mysql-community-server_8.0.22-1debian10_amd64.deb && wget https://repo.mysql.com/apt/debian/pool/mysql-8.0/m/mysql-community/mysql-server_8.0.22-1debian10_amd64.deb && \
dpkg -i mysql-server_8.0.22-1debian10_amd64.deb 
RUN apt-get -y update && apt-get -y install mysql-server 

RUN cd /var/www/html/ && wget https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz && touch .htaccess && chmod 660 .htaccess
RUN cd /var/www/html/wordpress/ && rm wp-config-sample.php
COPY wp-config.php /var/www/html/wordpress/
RUN cp -a /var/www/html/wordpress/. /var/www/html && cd /var/www/html && rm -rf wordpress
RUN cd /var/www/html/ && mkdir wp-content/upgrade
RUN cd /var/www/html/ && chown -R root:www-data /var/www/html && find /var/www/html -type d -exec chmod g+s {} \; \
&& chmod g+w /var/www/html/wp-content && chmod -R g+w /var/www/html/wp-content/themes && chmod -R g+w /var/www/html/wp-content/plugins
RUN cd /var/www/html/ && wget https://api.wordpress.org/secret-key/1.1/salt/
RUN cd /var/www/html/ && rm index.html
#COPY index.html /var/www/html/

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT bash docker-entrypoint.sh