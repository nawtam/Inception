*This project has been created as part of the 42 curriculum by ntamacha.*

---

# Inception

## Description
Inception is a 42 system administration project. The goal is to deploy a WordPress infrastructure using Docker Compose inside a virtual machine, with 3 services in dedicated containers: Nginx (HTTPS entry point), WordPress + PHP-FPM (application), and MariaDB (database). 

A full documentation website has been built alongside this project.
To access it, clone the repo, run `make`, then visit `https://ntamacha.42.fr`.

---

## Instructions

### Prerequisites

- A Debian virtual machine
- Docker: `curl -fsSL https://get.docker.com | sh`
- Make: `sudo apt-get install -y make`

### Installation

**1. Clone the repository**
```bash
git clone <repo_url> Inception
cd Inception
```

**2. Create the .env file**
```bash
nano srcs/.env
```

Fill in the following variables:
```env
DOMAIN_NAME=ntamacha.42.fr
LOGIN=ntamacha
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password
WP_ADMIN_USER=your_admin
WP_ADMIN_PASSWORD=your_password
WP_ADMIN_EMAIL=your_email
WP_USER=your_username
WP_USER_EMAIL=your_email
WP_USER_PASSWORD=your_password
```

**3. Add domain to /etc/hosts**
```bash
echo "127.0.0.1 ntamacha.42.fr" | sudo tee -a /etc/hosts
```

**4. Create data directories**
```bash
mkdir -p /home/ntamacha/data/db
mkdir -p /home/ntamacha/data/wp
```

**5. Build and launch**
```bash
make
```

### Access

- Website: `https://ntamacha.42.fr`
- Admin panel: `https://ntamacha.42.fr/wp-admin`

> A certificate warning will appear — this is expected for a self-signed certificate. Accept it to continue.

### Makefile commands

| Command | Description |
|---------|-------------|
| `make` | Build images and start all containers |
| `make down` | Stop containers, keep data |
| `make clean` | Stop containers, clean Docker cache |
| `make fclean` | Full cleanup including data |
| `make re` | Full rebuild from scratch |
| `make logs` | Follow all container logs |
| `make status` | Show container status |

---

## Project Description

### Use of Docker

Docker is used to isolate each service in its own container. Each container is built from a custom `Dockerfile` and orchestrated with `docker-compose.yml`. This ensures that each service has exactly the dependencies it needs, nothing more.

The `docker-compose.yml` defines 3 services, 2 named volumes, and 1 private bridge network. A single `make` command builds all images and starts the entire infrastructure.

### Main Design Choices

- All images are built from `debian:bullseye` — no pre-built service images allowed
- PHP-FPM listens on TCP `0.0.0.0:9000` instead of a Unix socket so Nginx can reach it from another container
- MariaDB uses `bind-address=0.0.0.0` to accept connections from the Docker network
- All scripts end with `exec` (e.g. `exec mysqld`, `exec php-fpm -F`) so the service becomes PID 1 and Docker can manage signals properly
- All credentials are stored in `.env` and never committed to Git

---

### Virtual Machines vs Docker

| | Virtual Machine | Docker Container |
|-|----------------|-----------------|
| **OS** | Full OS per VM | Shares host kernel |
| **Size** | Several GB | A few MB |
| **Startup** | Minutes | Seconds |
| **Isolation** | Complete hardware emulation | Process-level isolation |
| **Use case** | Full environment isolation | Service isolation |

A VM emulates a complete computer with its own OS. A Docker container shares the host kernel and only isolates the process and its dependencies. For Inception, running 3 separate VMs would be too heavy — 3 Docker containers achieve the same isolation with much less resource usage.

---

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|-|---------|----------------------|
| **Storage** | Files (e.g. `secrets/`) | `.env` file |
| **Security** | Only readable by the service that needs them | Visible to all processes in the container |
| **Use case** | Production environments | Development and simple projects |
| **Docker support** | Docker Swarm secrets | `env_file` in docker-compose |

Environment variables (via `.env`) are used in this project for simplicity. In production, Docker secrets would be the preferred approach as they are never exposed as environment variables and are only mounted as files inside the container.

---

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|-|------------------------|--------------|
| **Isolation** | Containers are isolated from the host | Container shares host network directly |
| **DNS** | Containers reach each other by service name | No automatic DNS resolution |
| **Security** | Only exposed ports are accessible | All ports are exposed |
| **Subject rule** | Required | Forbidden |

This project uses a private bridge network named `inception`. All containers connect to it and can reach each other using their service name (e.g. `mariadb:3306`). Using `network: host` is explicitly forbidden by the subject because it removes network isolation entirely.

---

### Docker Volumes vs Bind Mounts

| | Docker Named Volumes | Bind Mounts |
|-|---------------------|-------------|
| **Path on host** | Managed by Docker (`/var/lib/docker/volumes/`) | Explicit path chosen by user |
| **Portability** | High | Depends on host path |
| **Subject requirement** | Required — data in `/home/login/data` | Not allowed for persistent storage |
| **Survival after `down -v`** | Deleted | Files remain on host |

The subject requires named volumes with data stored in `/home/ntamacha/data/` on the host machine. This is implemented using `driver: local` with `driver_opts` (`type: none`, `o: bind`, `device: /home/ntamacha/data/...`), which combines the named volume syntax with a specific host path.

---

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [OpenSSL documentation](https://www.openssl.org/docs/)
- [Understanding PID 1 in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [TLS 1.2 vs TLS 1.3](https://www.cloudflare.com/learning/ssl/why-use-tls-1.3/)

### How AI was used

AI (Claude by Anthropic) was used during this project for the following tasks:

- **Documentation** generating the structure and content of `README.md`, `USER_DOC.md`, `DEV_DOC.md` and the WordPress documentation website

- **Explanations** 
understanding concepts like PID 1, FastCGI, Docker networking, TLS handshake, and PHP-FPM pool configuration
- **Debugging help** 
identifying causes of common errors (502 Bad Gateway, bind-address issues, permission denied on volumes)
