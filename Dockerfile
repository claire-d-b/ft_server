FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

# installation of last available packages :
# - free software of web werver nginx
# - php - programming language mainly used to create webpages
# php-fpm - communication intervace between php and the server
# mysql - database service to deploy native cloud applications using db

RUN apt-get -y update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y nginx php php-fpm wget
RUN apt-get install -y php7.3-mysql

# Amend default_nginx file to 
# - set the ports for connection : 80 http & 443 https.
# indicate root directory 
# set indexes manually or activate autoindex
# indicate the location of ssl certificates files
# PHP-FPM - interface SAPI - Server Application Programming Interface - permettant la communication entre un serveur Web et PHP, basée sur le protocole FastCGI.
# Socket - special file used for inter-process communication, which enables communication between two processes.
# .ht files - These files store your connection and terminal emulator settings as well as any Key Macros or file transfer settings you have set up.

RUN unlink /etc/nginx/sites-enabled/default && mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default_old
COPY default_nginx /etc/nginx/sites-available/default
RUN rm -rf /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN cd /etc/nginx/ && mkdir ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out \
/etc/nginx/ssl/nginx.crt -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42/OU=clde-ber/CN=helloworld"

# get phpMyAdmin - free software tool written in PHP, intended to handle the administration of MySQL over the Web.
# Amend config_php and fill the host and allownopasswd categories.
# Amend php.ini and fill the mysql socket, host and user categories.
RUN cd /var/www/html/ && wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz \
&& tar -xvzf phpMyAdmin-5.0.2-english.tar.gz && mv phpMyAdmin-5.0.2-english phpmyadmin && rm phpMyAdmin-5.0.2-english.tar.gz
COPY config_php var/www/html/phpmyadmin/config.inc.php
RUN rm /etc/php/7.3/fpm/php.ini
COPY php.ini /etc/php/7.3/fpm/php.ini


# unpack and install mysql 8.0.22 dep. to get installation candidate for mysql-server
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

# unpacking & intsallation of wordpress, amendments to wp-config.php with host, user, database name, passwd, charset used and allowance for repairing databases.
# chown giving the property of a file / directory to a specific user.
# chmod g+s inherit the group ID of specified directory.
# Amendments of user, group, others rights for updates when new version of worpress is available.
# Generating secret keys for authentification.
# Removing index.html so nginx welcome page appears when autoindex is set off.
RUN cd /var/www/html/ && wget https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz && touch .htaccess && chmod 660 .htaccess
RUN cd /var/www/html/wordpress/ && rm wp-config-sample.php
COPY wp-config.php /var/www/html/wordpress/
RUN cp -a /var/www/html/wordpress/. /var/www/html && cd /var/www/html && rm -rf wordpress
RUN cd /var/www/html/ && mkdir wp-content/upgrade
RUN cd /var/www/html/ && chown -R root:www-data /var/www/html && find /var/www/html -type d -exec chmod g+s {} \; \
&& chmod g+w /var/www/html/wp-content && chmod -R g+w /var/www/html/wp-content/themes && chmod -R g+w /var/www/html/wp-content/plugins
RUN cd /var/www/html/ && wget https://api.wordpress.org/secret-key/1.1/salt/
RUN cd /var/www/html/ && rm index.html


# Copy start script in the container and amend its rights so it can be executed as entrypoint.
# An ENTRYPOINT allows you to configure a container that will run as an executable.
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT bash docker-entrypoint.sh