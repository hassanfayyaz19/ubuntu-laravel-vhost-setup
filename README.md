# Ubuntu Laravel Virtual Host Setup

A bash script that automates the creation of Apache virtual hosts for Laravel projects on Ubuntu systems. This script handles PHP version management, Apache configuration, and local domain setup in one go.

## Features

- **PHP Version Management**: List and select from available PHP versions
- **Automatic Virtual Host Creation**: Creates Apache virtual host configuration files
- **Local Domain Setup**: Automatically adds entries to `/etc/hosts`
- **Laravel Optimized**: Configured specifically for Laravel's directory structure
- **Error Logging**: Sets up dedicated error and access logs for each project
- **Input Validation**: Validates PHP versions and project directories

## Prerequisites

- Ubuntu/Debian-based system
- Apache2 web server installed
- Multiple PHP versions installed (if you want version selection)
- Root/sudo privileges

### Installing Prerequisites

```bash
# Install Apache2
sudo apt update
sudo apt install apache2

# Install PHP (example for multiple versions)
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php7.4 php8.1 php8.3 php7.4-fpm php8.1-fpm php8.3-fpm

# Enable Apache modules
sudo a2enmod rewrite
sudo a2enmod php7.4  # or your preferred version
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/ubuntu-laravel-vhost-setup.git
cd ubuntu-laravel-vhost-setup
```

2. Make the script executable:
```bash
chmod +x setup-laravel-vhost.sh
```

## Usage

1. Run the script as root:
```bash
sudo ./setup-laravel-vhost.sh
```

2. Follow the interactive prompts:
   - Select your desired PHP version from the available options
   - Enter your Laravel project name (e.g., `myproject`)
   - Provide the absolute path to your Laravel project directory

3. The script will:
   - Set the selected PHP version as default
   - Create Apache virtual host configuration
   - Enable the virtual host
   - Add the local domain to `/etc/hosts`
   - Restart Apache

4. Access your Laravel project at `http://projectname.test`

## Example

```bash
$ sudo ./setup-laravel-vhost.sh

Available PHP versions:
/usr/bin/php7.4
/usr/bin/php8.1
/usr/bin/php8.3

Enter the PHP version you want to use (e.g., 7.4, 8.1, 8.3): 8.1
Default PHP version set to 8.1.

Enter the Laravel project name (e.g., myproject): myblog
Enter the absolute path to the Laravel project directory (e.g., /var/www/myproject): /var/www/myblog

Creating virtual host file: /etc/apache2/sites-available/myblog.conf
Added myblog.test to /etc/hosts.
Restarting Apache...
Virtual host for myblog created successfully with PHP 8.1.
You can access the project at http://myblog.test
```

## What the Script Does

1. **Validates Root Privileges**: Ensures the script is run with proper permissions
2. **PHP Version Management**: 
   - Lists available PHP versions using `update-alternatives`
   - Allows selection of desired PHP version
   - Sets the chosen version as system default
3. **Project Setup**:
   - Prompts for project name and directory path
   - Validates that the project directory exists
4. **Apache Configuration**:
   - Creates virtual host configuration file
   - Sets document root to Laravel's `public` directory
   - Configures proper directory permissions and URL rewriting
   - Sets up error and access logging
5. **Local Domain Setup**:
   - Adds project domain to `/etc/hosts` for local development
   - Uses `.test` TLD to avoid conflicts with real domains
6. **Service Management**:
   - Enables the new virtual host
   - Restarts Apache to apply changes

## Generated Virtual Host Configuration

The script creates a virtual host configuration similar to:

```apache
<VirtualHost *:80>
    ServerName projectname.test
    DocumentRoot /path/to/project/public
    <Directory /path/to/project/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/projectname_error.log
    CustomLog ${APACHE_LOG_DIR}/projectname_access.log combined
</VirtualHost>
```

## Troubleshooting

### Common Issues

1. **"Please run as root" error**:
   - Make sure to run the script with `sudo`

2. **"PHP version X.X is not installed" error**:
   - Install the requested PHP version: `sudo apt install phpX.X`

3. **"The specified directory does not exist" error**:
   - Create your Laravel project directory first
   - Ensure you're providing the absolute path

4. **Virtual host not accessible**:
   - Check if Apache is running: `sudo systemctl status apache2`
   - Verify the virtual host is enabled: `sudo a2ensite projectname.conf`
   - Check Apache error logs: `sudo tail -f /var/log/apache2/projectname_error.log`

### Verification Steps

```bash
# Check if virtual host is enabled
sudo apache2ctl -S

# Test Apache configuration
sudo apache2ctl configtest

# Check hosts file entry
grep "projectname.test" /etc/hosts

# Test domain resolution
ping projectname.test
```

## Security Notes

- This script is intended for local development environments
- The generated virtual hosts listen on port 80 (HTTP) without SSL
- For production use, consider adding HTTPS configuration
- Ensure proper file permissions on your Laravel project directories

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add some improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Create a Pull Request

## Changelog

### v1.0.0
- Initial release
- PHP version selection and management
- Automated virtual host creation
- Local domain configuration
- Input validation and error handling
