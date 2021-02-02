#!/bin/bash

#Part one - Deploy Pre-Requisites
#Installing FirewallD
function check_service_status(){
  service_is_active=$(sudo systemctl is-active $1)
  if [ $service_is_active = "active" ]
  then
    echo "$1 is active and running"
  else
    echo "$1 is not active/running"
    exit 1
  fi
}

#firewalld configuration
function is_firewalld_rule_configured(){
  firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)
  if [[ $firewalld_ports == *$1* ]]
  then
    echo "FirewallD has port $1 configured"
  else
    echo "FirewallD port $1 is not configured"
    exit 1
  fi
}

# Part Two - Deploy and Configure Database


# Install and configure firewalld
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld
check_service_status firewalld

# Install and configure Maria-DB
echo "MariaDB is being set up!"
sudo yum install -y mariadb-server
sudo service mariadb start
sudo systemctl enable mariadb
check_service_status mariadb

# Firewall Rules
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload
fd_ports=$(sudo firewall-cmd --list-all --zone=public |grep ports)
if[[$fd_portss = *3306*]]
  echo "3306 is configured and running"
else
  echo "Error in configuration of port 3306"



# Configuring Database
cat > setup-db.sql <<-EOF
  CREATE DATABASE ecomdb;
  CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
  FLUSH PRIVILEGES;
EOF

sudo mysql < setup-db.sql

# Inventory
print_color "green" "Loading inventory data into database"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

sudo mysql < db-load-script.sql

#Check if the inventory is loaded or not

mysql_db_result=$(sudo mysql -e "use ecomdb; select * from products:")
if[[ $mysql_db_result = *Laptop*]]
then
  echo "Loaded Successfully"
else
  echo "Inventory not Loaded"
  exit 1
fi


#Set and configure web server

sudo yum install -y httpd php php-mysql

# Configure firewalld rules
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80

# Update index.php
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start httpd service
sudo service httpd start
sudo systemctl enable httpd

check_service_status httpd

# Git clone
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

# Test Script
web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
  check_item "$web_page" $item
done