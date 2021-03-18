#!/bin/sh
sudo -s
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<html><h1>Hello guys! welcome to my Iya kekere website, we sell creams</h1><html>" > /var/www/html/index.html