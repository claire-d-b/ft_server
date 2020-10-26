FROM debian:buster


RUN apt-get -y update && apt-get -y upgrade && apt-get -y install apt-utils && apt-get -y dist-upgrade && apt-get -y install nginx php php-fpm wget
RUN apt-get -y install php7.3-mysql
RUN apt-get -y install default-mysql-server 

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

##RUN cd /var/www/html/ && wget https://wordpress.org/latest.tar.gz && tar -xzvf latest.tar.gz && touch .htaccess && chmod 660 .htaccess
##RUN cd /var/www/html/wordpress/ && rm wp-config-sample.php
##COPY wp-config.php /var/www/html/wordpress/
##RUN cp -a /var/www/html/wordpress/. /var/www/html && cd /var/www/html && rm -rf wordpress
##RUN cd /var/www/html/ && mkdir wp-content/upgrade
##RUN cd /var/www/html/ && chown -R root:www-data /var/www/html && find /var/www/html -type d -exec chmod g+s {} \;
##&& chmod g+w /var/www/html/wp-content && chmod -R g+w /var/www/html/wp-content/themes && chmod -R g+w /var/www/html/wp-content/plugins
##RUN cd /var/www/html/ && wget https://api.wordpress.org/secret-key/1.1/salt/
##RUN cd /var/www/html/ && rm index.html
##COPY index.html /var/www/html/

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT bash docker-entrypoint.sh

##RUN apt-get -y install php7.3-mysql
## doute sur démarrage de phpfpm
##RUN cd /var/www/html/ && wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb
##RUN DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.13-1_all.deb
##RUN touch /var/run/mysqld/mysqld.sock && ln -s /var/run/mysqld/mysqld.sock /tmp/mysqld.sock && chmod 0755 /var/run/mysqld && chown mysql:root /var/run/mysqld
##RUN rm /etc/mysql/my.cnf
##COPY my.cnf /etc/mysql/my.cnf
##RUN mysql_secure_installation --user=root --host=localhost --port=3306
##RUN cd /var/www/html/ && apt-get -y update && apt-get -y install gnupg && apt -y update && apt -y install default-mysql-server
##RUN cd /var/run/mysqld && touch mysqld.sock && chmod +x mysqld.sock
##RUN service mysqld start
##RUN mysql /run/mysqld -h localhost -u root --skip-password
##RUN service mysqladmin start
##RUN cd /var/run/mysqld && touch mysqld.sock && chmod +x mysqld.sock && chown mysql:mysql -R * && cd /tmp && ln -s /var/run/mysqld/mysqld.sock mysqld.sock
##RUN echo "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysqladmin -u root --bind-address=localhost status
##RUN echo "GRANT ALL ON wordpress.* TO 'root'@'localhost' IDENTIFIED BY '';" | mysqladmin -u root --bind-address=localhost status
##RUN echo "FLUSH PRIVILEGES;" | mysqladmin -u --bind-address=localhost status