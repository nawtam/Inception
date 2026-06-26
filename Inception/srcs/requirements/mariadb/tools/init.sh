#!/bin/bash

if [ ! -f "/var/lib/mysql/ibdata1" ]; then
    echo "Premier démarrage : initialisation de MariaDB..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1

    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &

    echo "Attente du socket..."
    while [ ! -S /run/mysqld/mysqld.sock ]; do
        sleep 1
    done
    echo "Socket prêt."

    mysql -u root <<-EOSQL
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    echo "Base créée avec succès."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    sleep 2
fi

echo "Démarrage de MariaDB..."
exec mysqld --user=mysql
