.ONESHELL:
ENV_PREFIX=venv/bin

include .env
include .secrets.env

.PHONY: help show install update_requirements clean config_pre-commit
.PHONY: database stop_database clean_image build_image
.PHONY: lint pre-commit

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

config_pre-commit:          ## Config pre-commit.
	@pip install pre-commit==2.20
	@pre-commit install

install:                    ## Create a virtual environment and install requirements.
	@echo "creating virtualenv ..."
	@rm -rf venv
	@virtualenv -q venv || python3 -m venv venv

	@echo "installing requirements ..."
	@$(ENV_PREFIX)/pip install -q -r requirements.txt
	@$(ENV_PREFIX)/dbt -q deps

	@echo
	@echo "!!! Please run 'source $(ENV_PREFIX)/activate' to enable the environment !!!"

update_requirements:        ## Upgrade requirements and save them.
	@echo "creating virtualenv ..."
	@rm -rf venv

	@echo "updating requirements ..."
	@sed 's/==/>=/g' requirements.txt > TMP_FILE && mv TMP_FILE requirements.txt
	@virtualenv -q venv || python3 -m venv venv
	@$(ENV_PREFIX)/pip install -q -r requirements.txt

	@echo "updated requirements."
	@$(ENV_PREFIX)/pip freeze > requirements.txt
	@$(ENV_PREFIX)/dbt -q deps

	@echo
	@echo "!!! Please run 'source $(ENV_PREFIX)/activate' to enable the environment !!!"

docs:                       ## Create and serve dbt docs.
	@export DBT_PROFILES_DIR=".dbt/"
	@$(ENV_PREFIX)/dbt docs generate
	@$(ENV_PREFIX)/dbt docs serve

clean:                      ## Clean unused files.
	@rm -rf venv
	@rm -rf target/*
	@rm -rf logs/*
	@rm -rf dbt_packages/

################# Linting #################
lint:                       ## Lint changed files with sqlfluff
	@pre-commit run sqlfluff-lint
	@pre-commit run sqlfluff-fix

pre-commit:                 ## Run pre-commit hooks for changed files
	@pre-commit run

pre-commit_all_files:       ## Run pre-commit hooks for all files
	@pre-commit run --all-files

############ Running in docker ############
database:                   ## Start database.
	@echo "Starting database with image $(POSTGRES_IMAGE)."
	@docker compose up -d

stop_database:              ## Stop database.
	@echo "Stoping database."
	@docker compose down

clean_image:                ## Remove dbt docker image.
	@docker rmi $(IMAGE_NAME):$(IMAGE_VERSION)

build_image:                ## Build dbt docker image.
	@docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .
