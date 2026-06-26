#!/bin/bash
set -e

echo "Attente de MariaDB..."
while ! mysqladmin ping -h mariadb --silent 2>/dev/null; do
    sleep 1
done
echo "MariaDB est prêt."

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Installation de WordPress..."

    wp core download --allow-root --path=/var/www/html

    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306

    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email

    wp user create \
        --allow-root \
        --path=/var/www/html \
        ${WP_USER} ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author

    chown -R www-data:www-data /var/www/html
    echo "WordPress installé."
fi

exec php-fpm8.2 -F
