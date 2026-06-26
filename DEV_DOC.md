# Developer Documentation

## Project Structure

Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/my.cnf
        │   └── tools/init.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/init.sh
        └── nginx/
            ├── Dockerfile
            ├── conf/nginx.conf
            └── tools/init.sh

## Prerequisites

- Debian VM
- Docker : curl -fsSL https://get.docker.com | sh
- make : sudo apt-get install -y make
- Add to /etc/hosts : 127.0.0.1 ntamacha.42.fr

## Setup from Scratch

1. Clone the repository
git clone <your_repo> Inception
cd Inception

2. Create the .env file
nano srcs/.env

Fill in all variables:
DOMAIN_NAME=ntamacha.42.fr
LOGIN=ntamacha
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password
WP_ADMIN_USER=your_admin (no "admin" in name)
WP_ADMIN_PASSWORD=your_password
WP_ADMIN_EMAIL=your_email
WP_USER=your_username
WP_USER_EMAIL=your_email
WP_USER_PASSWORD=your_password

3. Create data directories
mkdir -p /home/ntamacha/data/db
mkdir -p /home/ntamacha/data/wp

4. Build and launch
make

## Makefile Commands

make        → Build and start all containers
make down   → Stop containers, keep data
make clean  → Stop containers, clean Docker cache
make fclean → Full cleanup including data
make re     → Full rebuild
make logs   → Follow all logs
make status → Show container status

## Docker Commands

Enter a container:
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

View logs:
docker logs mariadb
docker logs wordpress
docker logs nginx

List volumes:
docker volume ls

Inspect network:
docker network inspect srcs_inception

## Database

Connect to MariaDB:
docker exec -it mariadb mysql -u root -p

Useful SQL commands:
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT User, Host FROM mysql.user;

## Data Persistence

Volume    | Container path  | Host path
db_data   | /var/lib/mysql  | /home/ntamacha/data/db
wp_data   | /var/www/html   | /home/ntamacha/data/wp

Data survives make down + make.
Only make fclean deletes everything.

## Architecture

Browser
  │ HTTPS port 443
  ▼
NGINX (TLS 1.2/1.3)
  │ FastCGI port 9000
  ▼
WordPress + PHP-FPM
  │ MySQL port 3306
  ▼
MariaDB

## Startup Sequence

1. MariaDB   → init DB if first run → mysqld as PID 1
2. WordPress → wait for MariaDB → install WP if first run → php-fpm as PID 1
3. NGINX     → generate SSL cert → serve site as PID 1

## TLS Configuration

NGINX only accepts TLSv1.2 and TLSv1.3.
Self-signed certificate generated at startup with openssl.
Certificate stored at /etc/nginx/ssl/inception.crt
