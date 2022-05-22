.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")
IMAGE_NAME="dbt-cristian"
IMAGE_VERSION="0.1.0" # TODO get version from dbt_project.yml

.PHONY: help
help: ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: show
show: ## Show the current environment.
	@echo "Current environment:"
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@$(ENV_PREFIX)python -m site

.PHONY: install
install: ## Create a virtual environment and install .
	@echo "creating virtualenv ..."
	@rm -rf .venv
	@virtualenv .venv
	@./.venv/bin/pip install -r requirements.txt
	@echo
	@echo "!!! Please run 'source .venv/bin/activate' to enable the environment !!!"

.PHONY: clean
clean: ## Clean unused files.
	@rm -rf .venv
	@rm -rf target/*
	@rm -rf logs/*
	@rm -rf dbt_packages/

.PHONY: start_postgres ## Start postgres database
start_postgres:
	@docker compose up -d

.PHONY: stop_postgres ## Stop postgres database
stop_postgres:
	@docker compose down

.PHONY: build_image ## Build dbt image
build_image:
	@docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .

.PHONY: run_image ## Run dbt image with a bridge network with postgres container
run_image:
	@docker run --net dbt_network -t $(IMAGE_NAME):$(IMAGE_VERSION) bash \
	||  echo "\nPostgres container is down!! Running without a network\n" \
		&& docker run -t $(IMAGE_NAME):$(IMAGE_VERSION) bash


# TODO Fix this
.PHONY: dbt_run
dbt_run: ## Run dbt using the profiles.yml in project
	@dbt run --profiles-dir .

.PHONY: dbt_test
dbt_test: ## Run dbt tests commands using the profiles.yml in project
	@dbt test --profiles-dir .
