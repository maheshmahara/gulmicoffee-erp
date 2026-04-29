# ============================================================
# Gulmi Coffee ERP — Makefile
# Usage: make <command>
# ============================================================

IMAGE_NAME  = gulmi-coffee-erp
CONTAINER   = gulmi-erp
PORT        = 80

.PHONY: help build up down restart logs shell update clean ps health

help:
	@echo ""
	@echo "  Gulmi Coffee ERP — Docker Commands"
	@echo "  ─────────────────────────────────────────"
	@echo "  make build    Build the Docker image"
	@echo "  make up       Start all containers (detached)"
	@echo "  make down     Stop and remove containers"
	@echo "  make restart  Restart the ERP container"
	@echo "  make logs     Follow container logs"
	@echo "  make shell    Open shell inside container"
	@echo "  make update   Rebuild image and restart"
	@echo "  make clean    Remove containers, volumes, images"
	@echo "  make ps       Show running containers"
	@echo "  make health   Check container health"
	@echo "  make prod     Start with SSL (production)"
	@echo ""

build:
	docker compose build --no-cache

up:
	docker compose up -d
	@echo ""
	@echo "  Gulmi Coffee ERP is running at:"
	@echo "  http://localhost:$(PORT)"
	@echo ""

down:
	docker compose down

restart:
	docker compose restart $(CONTAINER)

logs:
	docker compose logs -f $(CONTAINER)

shell:
	docker exec -it $(CONTAINER) /bin/sh

update:
	docker compose build --no-cache
	docker compose up -d --force-recreate
	@echo "ERP updated and restarted."

clean:
	docker compose down -v --rmi local
	@echo "All containers, volumes, and local images removed."

ps:
	docker compose ps

health:
	@curl -sf http://localhost:$(PORT)/health > /dev/null && \
		echo "  Status: HEALTHY - Gulmi ERP is running" || \
		echo "  Status: UNHEALTHY - check: make logs"

prod:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@echo "Production ERP with SSL started."
