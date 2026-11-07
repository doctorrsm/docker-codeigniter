.PHONY: up down restart logs shell composer spark install env env-if-missing

export HOST_UID := $(shell id -u)
export HOST_GID := $(shell id -g)

up: env-if-missing
	docker compose up -d --build
	@$(MAKE) install

env-if-missing:
	@test -f .env || cp .env.example .env
	@if [ ! -f src/.env ]; then $(MAKE) env; fi

env:
	@test -f .env || cp .env.example .env
	@bash bin/render-env

install:
	docker compose up -d
	@i=0; \
	until docker compose exec -T app true >/dev/null 2>&1; do \
	  i=$$((i + 1)); \
	  if [ "$$i" -gt 30 ]; then echo "PHP container did not start" >&2; exit 1; fi; \
	  sleep 1; \
	done
	docker compose exec -T -u www-data -e HOME=/tmp -e COMPOSER_HOME=/tmp/composer app install-app.sh
	@if [ ! -f src/.env ]; then $(MAKE) env; fi

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f --tail=200

shell:
	docker compose exec -u www-data -e HOME=/tmp app sh

composer:
	docker compose exec -u www-data -e HOME=/tmp -e COMPOSER_HOME=/tmp/composer app composer $(c)

spark:
	docker compose exec -u www-data -e HOME=/tmp app php spark $(c)
