.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")

.PHONY: help
help:             ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: show
show:             ## Show the current environment.
	@echo "Current environment:"
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@$(ENV_PREFIX)python -m site

.PHONY: install
install:       ## Create a virtual environment and install .
	@echo "creating virtualenv ..."
	@rm -rf .venv
	@virtualenv .venv
	@./.venv/bin/pip install -r requirements.txt
	@echo
	@echo "!!! Please run 'source .venv/bin/activate' to enable the environment !!!"

.PHONY: clean
clean:            ## Clean unused files.
	@rm -rf .venv
	@rm -rf target/*
	@rm -rf logs/*
	@rm -rf dbt_packages/


# TODO Fix this
.PHONY: dbt-run
dbt-run:              ## Run dbt using the profiles.yml in project
	@dbt run --profiles-dir .

.PHONY: dbt-test
dbt-test:              ## Run dbt tests commands using the profiles.yml in project
	@dbt test --profiles-dir .
