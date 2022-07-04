.ONESHELL:
ENV_PREFIX='venv/bin'

include .env

.PHONY: help show install update_requirements clean
.PHONY: database stop_database clean_image build_image
.PHONY: lint

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

################# Linting ################# 
lint:                       ## Lint the project with sqlfluff
	@$(ENV_PREFIX)/sqlfluff lint dbt_project/ --dialect postgres

############ Running in docker ############ 
database:                   ## Start database.
	@echo "Starting database with image $(POSTGRES_IMAGE)."
	@docker compose up -d
 
stop_database:              ## Stop database.
	@echo "Stoping database."
	@docker compose down

clean_image:                ## Remove database and dbt images.
	@docker rmi $(IMAGE_NAME):$(IMAGE_VERSION)

build_image:                ## Build dbt docker image
	@docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .
