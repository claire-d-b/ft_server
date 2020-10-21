FROM debian:buster
RUN apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get install -y nginx php php-fpm wget
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default_old
COPY default_nginx /etc/nginx/sites-available/default
RUN cd /var/www/html/ && wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz && tar -xvzf phpMyAdmin-5.0.2-english.tar.gz && mv phpMyAdmin-5.0.2-english phpmyadmin && rm phpMyAdmin-5.0.2-english.tar.gz
COPY config_php var/www/html/phpmyadmin/config.inc.php
RUN rm /etc/php/7.3/fpm/php.ini
COPY php.ini /etc/php/7.3/fpm/php.ini
## doute sur démarrage de phpfpm
##RUN cd /var/www/html/ && wget http://repo.mysql.com/mysql-apt-config_0.8.13-1_all.deb
##RUN DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.13-1_all.deb
RUN apt-get -y update && cd /var/www/html/ && apt-get -y install default-mysql-server
ENTRYPOINT ["nginx", "-g", "daemon off;"]