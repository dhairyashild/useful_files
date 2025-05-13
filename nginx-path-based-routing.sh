#! /bin/bash
sudo apt-get update -y 
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
mkdir -p /var/www/html/test
echo "my hostname= $(hostname)" >/var/www/html/test/index.html
