.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")

include .env

.PHONY: help
help:                          ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: show
show:                          ## Show the current environment.
	@echo "Current environment:"
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@$(ENV_PREFIX)python -m site

.PHONY: install
install:                       ## Create a virtual environment and install requirements.
	@echo "creating virtualenv ..."
	@rm -rf venv
	@virtualenv venv || python3 -m venv venv
	@./venv/bin/pip install -r requirements.txt
	@echo
	@echo "!!! Please run 'source venv/bin/activate' to enable the environment !!!"

.PHONY: clean
clean:                         ## Clean unused files.
	@rm -rf venv
	@rm -rf target/*
	@rm -rf logs/*
	@rm -rf dbt_packages/

.PHONY: start_services 
start_services:                ## Start database and build and start dbt container.
	@docker compose up -d

.PHONY: stop_services 
stop_services:                 ## Stop database and dbt containers.
	@docker compose down

.PHONY: build_image
build_image:
	@docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .

.PHONY: dbt 
dbt:                           ## Enter in container to start running dbt commands
	@docker exec -it dbt_instance bash
