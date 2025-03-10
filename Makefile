.DEFAULT_GOAL := help

ACTIVATE = . venv/bin/activate &&
ANSIBLE = $(ACTIVATE) ansible-playbook -i ./ansible/inventory.yaml
PROJECT_NAME = service
COMPOSE = docker compose

include .env
export

COMPOSE = docker compose -f compose.yaml
ifeq (${CERT_RESOLVER},pebble)
	COMPOSE += -f compose.pebble.yaml
endif

PROXY_FILES = $(shell find proxy -type f -name '*')

define usage
	@printf "\nUsage: make <command>\n"
	@grep -F -h "##" $(MAKEFILE_LIST) | grep -F -v grep -F | sed -e 's/\\$$//' | awk 'BEGIN {FS = ":*[[:space:]]*##[[:space:]]*"}; \
	{ \
		if($$2 == "") \
			pass; \
		else if($$0 ~ /^#/) \
			printf "\n%s\n", $$2; \
		else if($$1 == "") \
			printf "     %-20s%s\n", "", $$2; \
		else \
			printf "\n    \033[1;33m%-20s\033[0m %s\n", $$1, $$2; \
	}'
endef

.git/hooks/pre-commit: .pre-commit-config.yaml
	@if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then \
		$(ACTIVATE) pre-commit install --hook-type pre-commit; \
		@touch $@; \
	fi

venv: venv/.touchfile .git/hooks/pre-commit
venv/.touchfile: requirements.txt
	@test -d venv || python3 -m venv venv
	@$(ACTIVATE) pip install -U uv && uv pip install -Ur requirements.txt
	@touch $@

.PHONY: up
up: proxy mysql redis

.PHONY: down
down: redis-down mysql-down proxy-down

.PHONY: restart
restart: down up

.PHONY: proxy
proxy: venv network
	@$(ANSIBLE) ./ansible/proxy.yaml
	@$(COMPOSE) --profile proxy up --detach --build

.PHONY: proxy-down
proxy-down:
	@$(COMPOSE) --profile proxy down --remove-orphans

.PHONY: proxy-sh
proxy-sh:
	@$(COMPOSE) --profile proxy exec proxy bash

.PHONY: mysql
mysql:
	@$(COMPOSE) --profile mysql up --detach --build

.PHONY: mysql-down
mysql-down:
	@$(COMPOSE) --profile mysql down --remove-orphans

.PHONY: mysql-sh
mysql-sh:
	@$(COMPOSE) --profile mysql exec mysql bash

.PHONY: redis
redis:
	@$(COMPOSE) --profile redis up --detach --build

.PHONY: redis-down
redis-down:
	@$(COMPOSE) --profile redis down --remove-orphans

.PHONY: redis-sh
redis-sh:
	@$(COMPOSE) --profile redis exec redis bash

.PHONY: network
network:
	@docker network create $(PROJECT_NAME) || true

.PHONY: network-down
network-down:
	@docker network rm $(PROJECT_NAME) || true
