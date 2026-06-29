# User Documentation — Inception 42

## What services are provided

This project runs 3 services inside Docker containers:

| Service | Role | Port |
|---------|------|------|
| **Nginx** | Web server — only entry point of the infrastructure | 443 (HTTPS) |
| **WordPress** | Website engine — generates pages via PHP-FPM | 9000 (internal) |
| **MariaDB** | Database — stores all WordPress content | 3306 (internal) |

Only Nginx is accessible from outside. WordPress and MariaDB communicate only on the internal Docker network.

---

## Start and stop the project

**Start everything:**
```bash
cd ~/Inception
make
```

**Stop containers (data is kept):**
```bash
make down
```

**Full reset (deletes all data):**
```bash
make fclean
make
```

**Check that everything is running:**
```bash
make status
```

---

## Access the website

**Public website:**
```
https://ntamacha.42.fr
```

> A security warning will appear because the certificate is self-signed. This is normal — click "Advanced" then "Accept the risk and continue".

**WordPress administration panel:**
```
https://ntamacha.42.fr/wp-admin
```

Login with the admin credentials defined in `srcs/.env`:
- Username: value of `WP_ADMIN_USER`
- Password: value of `WP_ADMIN_PASSWORD`

---

## Locate and manage credentials

All credentials are stored in `srcs/.env` at the root of the project.

```bash
cat srcs/.env
```

This file contains:

| Variable | Description |
|----------|-------------|
| `MYSQL_USER` | WordPress database user |
| `MYSQL_PASSWORD` | WordPress database password |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password |
| `WP_ADMIN_USER` | WordPress admin username |
| `WP_ADMIN_PASSWORD` | WordPress admin password |
| `WP_USER` | Second WordPress user (author) |
| `WP_USER_PASSWORD` | Second user password |

> **Important:** The `.env` file is never committed to Git. Keep it secure on your machine.

---

## Check that the services are running correctly

**Check all containers are up:**
```bash
docker compose -f srcs/docker-compose.yml ps
```

All 3 containers should show status `running`.

**Check logs in real time:**
```bash
make logs
```

Or for a specific service:
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

**Check that HTTPS works:**
```bash
curl -k https://ntamacha.42.fr
```

Should return HTML content.

**Check that HTTP is blocked (port 80):**
```bash
curl http://ntamacha.42.fr
```

Should return `Connection refused` this is correct behavior.

**Check TLS version:**
```bash
openssl s_client -connect ntamacha.42.fr:443 | grep Protocol
```

Should show `TLSv1.3` or `TLSv1.2`.

**Connect to the database:**
```bash
docker exec -it mariadb mysql -u root -p
```

Then check:
```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```