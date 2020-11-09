# start mysql server locating the pid file in another place than the default insecure /tmp.
# -D --daemonize This option causes the server to run as a traditional, forking daemon, permitting it
# to work with operating systems that use systemd for process control. 
mysqld --pid-file=/var/run/mysqld/mysqld.pid --user=root -D
# WITH GRANT OPTION creates a MySQL user that can edit the permissions of other users.
# set the plugin so it is no more the default sha256_password plugin - was introduced in MySQL Server 5.6, and provides
# additional security focused on password storage.
# For the new user rights to be taken into account, a flush request has to be sent.
echo "CREATE DATABASE wordpress;" | mysql --port=13306 --host=localhost --user=root
echo "USE wordpress;" | mysql --port=13306 --host=localhost --user=root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql --port=13306 --host=localhost --user=root
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql --port=13306 --host=localhost --user=root
echo "FLUSH PRIVILEGES;" | mysql --port=13306 --host=localhost --user=root
if [ "$AUTOINDEX" = "on" ] ;
then mv srcs/default_nginx_ai_on /etc/nginx/sites-available/default ;
else mv srcs/default_nginx_ai_off /etc/nginx/sites-available/default ;
fi
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default ;
service nginx reload
service nginx start
# -g sets global directives
# a daemon is a computer program that runs as a background process, rather than being under the direct control of an interactive user.
# daemon off directive prevents the container for stopping right after the command is executed, which would be the standard behavior of a conainter.
nginx -g daemon off;
service php7.3-fpm start
bash