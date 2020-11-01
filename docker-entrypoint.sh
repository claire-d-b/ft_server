mysqld --pid-file=/var/run/mysqld/mysqld.pid --user=root -D && \
echo "CREATE DATABASE wordpress;" | mysql --port=13306 --host=localhost --user=root && \
echo "USE wordpress;" | mysql --port=13306 --host=localhost --user=root && \
echo "GRANT ALL ON wordpress.* TO 'root'@'localhost';" | mysql --port=13306 --host=localhost --user=root && \
echo "FLUSH PRIVILEGES;" | mysql --port=13306 --host=localhost --user=root && echo "EXIT;" | mysql --port=13306 --host=localhost --user=root && \
echo "connect wordpress;" | mysql --port=13306 --host=localhost --user=root
service nginx start
nginx -g daemon off;
service php7.3-fpm start
bash