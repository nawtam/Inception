NAME = inception

all: up

up:
	mkdir -p /home/ntamacha/data/db
	mkdir -p /home/ntamacha/data/wp
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

stop:
	docker compose -f srcs/docker-compose.yml stop

start:
	docker compose -f srcs/docker-compose.yml start

clean: down
	docker system prune -f
	sudo rm -rf /home/ntamacha/data/db/*
	sudo rm -rf /home/ntamacha/data/wp/*

fclean: clean
	docker system prune -af
	docker volume prune -f

re: fclean all

status:
	docker compose -f srcs/docker-compose.yml ps

logs:
	docker compose -f srcs/docker-compose.yml logs -f

.PHONY: all up down stop start clean fclean re status logs