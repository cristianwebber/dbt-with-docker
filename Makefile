.ONESHELL:
ENV_PREFIX=$(shell python3 -c "if __import__('pathlib').Path('venv/bin/pip').exists(): print('venv/bin')")

include .env
include .secrets.env

.PHONY: help show install update_requirements clean start_services stop_services clean_image build_image lint

help:                       ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

############## Running local ##############
show:                       ## Show the current environment.
	@echo "Current environment:"
	@echo "Running using $(ENV_PREFIX)/"
	@$(ENV_PREFIX)/python3 -V
	@$(ENV_PREFIX)/python3 -m site

install:                    ## Create a virtual environment and install requirements.
	@echo "creating virtualenv ..."
	@rm -rf venv
	@virtualenv venv || python3 -m venv venv
	@$(ENV_PREFIX)/pip install -r requirements.txt
	@$(ENV_PREFIX)/dbt deps
	@echo
	@echo "!!! Please run 'source $(ENV_PREFIX)/activate' to enable the environment !!!"

update_requirements:        ## Upgrade requirements and save them.
	@$(ENV_PREFIX)/pip install --upgrade --force-reinstall -r requirements.txt
	@$(ENV_PREFIX)/pip freeze > requirements.txt

clean:                      ## Clean unused files.
	@rm -rf venv
	@rm -rf target/*
	@rm -rf logs/*
	@rm -rf dbt_packages/

############ Running in docker ############ 
start_services:             ## Start database.
	@docker compose up -d
 
stop_services:              ## Stop database.
	@docker compose down

clean_image:                ## Remove database and dbt images.
	@docker rmi $(IMAGE_NAME):$(IMAGE_VERSION)

build_image:                ## Build dbt docker image
	@docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .

lint:                       ## Lint the project with sqlfluff
	@$(ENV_PREFIX)/sqlfluff lint dbt_project/ --dialect postgres
