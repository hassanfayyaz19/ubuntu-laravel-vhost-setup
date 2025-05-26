#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# List available PHP versions
echo "Available PHP versions:"
update-alternatives --list php

# Ask for the PHP version to use
read -p "Enter the PHP version you want to use (e.g., 7.4, 8.1, 8.3): " php_version

# Validate the PHP version
php_path="/usr/bin/php${php_version}"
if [ ! -f "$php_path" ]; then
    echo "PHP version $php_version is not installed."
    exit
fi

# Set the selected PHP version as default
update-alternatives --set php "${php_path}"
update-alternatives --set phar "/usr/bin/phar${php_version}"
update-alternatives --set phar.phar "/usr/bin/phar.phar${php_version}"
update-alternatives --set phpize "/usr/bin/phpize${php_version}"
update-alternatives --set php-config "/usr/bin/php-config${php_version}"
echo "Default PHP version set to ${php_version}."

# Ask for project name and path
read -p "Enter the Laravel project name (e.g., myproject): " project_name
read -p "Enter the absolute path to the Laravel project directory (e.g., /var/www/myproject): " project_path

# Validate project directory
if [ ! -d "$project_path" ]; then
    echo "The specified directory does not exist. Please create it first."
    exit
fi

# Create the virtual host configuration
vhost_config="/etc/apache2/sites-available/${project_name}.conf"
echo "Creating virtual host file: $vhost_config"
cat <<EOL > "$vhost_config"
<VirtualHost *:80>
    ServerName ${project_name}.test
    DocumentRoot ${project_path}/public

    <Directory ${project_path}/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${project_name}_error.log
    CustomLog \${APACHE_LOG_DIR}/${project_name}_access.log combined
</VirtualHost>
EOL

# Enable the new virtual host
a2ensite "${project_name}.conf"

# Add the host to /etc/hosts
host_entry="127.0.0.1 ${project_name}.test"
if ! grep -q "$host_entry" /etc/hosts; then
    echo "$host_entry" >> /etc/hosts
    echo "Added ${project_name}.test to /etc/hosts."
else
    echo "${project_name}.test already exists in /etc/hosts."
fi

# Restart Apache
echo "Restarting Apache..."
systemctl restart apache2

echo "Virtual host for ${project_name} created successfully with PHP ${php_version}."
echo "You can access the project at http://${project_name}.test"
