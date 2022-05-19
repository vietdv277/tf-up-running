#!/bin/bash

sudo apt-get update
sudo apt-get install -y net-tools
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

cat << EOF | sudo tee /var/www/html/index.html
<h1>The page was created by the user data</h1>
<p>Database Address: ${db_address}</p>
<p>Database Port: ${db_port}</p>
EOF