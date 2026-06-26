# User Documentation

## Services

| Service | Role |
|---------|------|
| NGINX | Web server, HTTPS entry point on port 443 |
| WordPress | Website and blog |
| MariaDB | Database |

## Start and Stop

```bash
# Start
cd ~/Inception
make

# Stop (keeps data)
make down

# Restart
make down && make
```

## Access

| Page | URL |
|------|-----|
| Website | https://ntamacha.42.fr |
| Admin panel | https://ntamacha.42.fr/wp-admin |

> Note: Your browser will show a security warning (self-signed certificate).
> Click "Advanced" then "Accept the risk" to continue.

## Credentials

All credentials are stored in `srcs/.env`.

| Account | Variable |
|---------|----------|
| WordPress admin username | WP_ADMIN_USER |
| WordPress admin password | WP_ADMIN_PASSWORD |
| WordPress user username | WP_USER |
| WordPress user password | WP_USER_PASSWORD |
| MariaDB user | MYSQL_USER |
| MariaDB password | MYSQL_PASSWORD |
| MariaDB root password | MYSQL_ROOT_PASSWORD |

## Check Services

```bash
# View running containers (all 3 must show "Up")
docker ps

# View logs
docker logs mariadb
docker logs wordpress
docker logs nginx

# Test website response
curl -k https://ntamacha.42.fr
```

## Data Location

| Data | Host path |
|------|-----------|
| MariaDB database | /home/ntamacha/data/db/ |
| WordPress files | /home/ntamacha/data/wp/ |

Data persists across restarts. Only `make fclean` deletes it.
