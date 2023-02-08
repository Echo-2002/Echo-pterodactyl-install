#!/bin/bash

# Author: Cameron
# Copyright: This script is provided as is without any warranty. Use it at your own risk.

# Ask which component to install
echo "What component would you like to install? (panel, wings, or both, default: both):"
read -r component
component=${component:-both}

# Ask for the database name
echo "Enter the name of the database you want to use for the Pterodactyl Panel (default: panel):"
read -r db_name
db_name=${db_name:-panel}

# Ask for the username
echo "Enter the name of the user you want to use for the Pterodactyl Panel (default: panel):"
read -r db_user
db_user=${db_user:-panel}

# Ask for the password
echo "Enter the password you want to use for the Pterodactyl Panel user:"
read -r db_password

# Ask for Let's Encrypt SSL certificate for Panel
if [ "$component" = "both" ] || [ "$component" = "panel" ]; then
  echo "Do you want to install a Let's Encrypt SSL certificate for the Pterodactyl Panel? (y/n, default: y):"
  read -r install_panel_ssl
  install_panel_ssl=${install_panel_ssl:-y}
fi

# Ask for Let's Encrypt SSL certificate for Wings
if [ "$component" = "both" ] || [ "$component" = "wings" ]; then
  echo "Do you want to install a Let's Encrypt SSL certificate for Pterodactyl Wings? (y/n, default: y):"
  read -r install_wings_ssl
  install_wings_ssl=${install_wings_ssl:-y}
fi

# Update the system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl git unzip mariadb-server

# Secure the MariaDB installation
sudo mysql_secure_installation

# Create a new database for the Pterodactyl Panel
echo "Creating a new database for the Pterodactyl Panel..."
mysql -u root -p -e "CREATE DATABASE ${db_name};"

# Create a new user for the Pterodactyl Panel
echo "Creating a new user for the Pterodactyl Panel..."
mysql -u root -p -e "CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';"

# Grant the user privileges on the database
mysql -u root -p -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Install the Pterodactyl Panel
if [ "$component" = "both" ] || [ "$component" = "panel" ]; then
  # Download the latest version of the Pterodactyl Panel
  latest_panel_version=$(curl -Ls https://api.github.com/repos/pterodactyl/panel/releases/latest | grep 'tag_name' | cut -d
