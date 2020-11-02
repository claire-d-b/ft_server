mysqld --pid-file=/var/run/mysqld/mysqld.pid --user=root -D
echo "CREATE DATABASE wordpress;" | mysql --port=13306 --host=localhost --user=root
echo "USE wordpress;" | mysql --port=13306 --host=localhost --user=root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql --port=13306 --host=localhost --user=root
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql --port=13306 --host=localhost --user=root
echo "FLUSH PRIVILEGES;" | mysql --port=13306 --host=localhost --user=root
service nginx start
nginx -g daemon off;
service php7.3-fpm start
bash