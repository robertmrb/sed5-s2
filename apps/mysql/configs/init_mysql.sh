#!/bin/bash



# mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
# mysql -e "CREATE USER IF NOT EXISTS 'wp_admin'@'localhost' IDENTIFIED BY 'Password#1';"
# mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_admin'@'localhost';"
# mysql -e "FLUSH PRIVILEGES;"

# # Keep container running
# service mysql restart && tail -f /dev/null

# set -e
echo "starting mysql… "
service mysql start
mysql -u root <<-EOSQL
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_admin'@'localhost' IDENTIFIED BY 'Password#1';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_admin'@'localhost';
FLUSH PRIVILEGES;
EOSQL
