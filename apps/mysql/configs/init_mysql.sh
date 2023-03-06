#!/bin/bash

service mysql start
mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql -e "CREATE USER IF NOT EXISTS 'wp_admin'@'localhost' IDENTIFIED BY 'Password#1';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_admin'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Keep container running
tail -f /dev/null
