########################################################################################
.PHONY: all

########################################################################################
# useful constants
REPO := martibosch/cookiecutter-django-tfdo-demo
ENVS_PRODUCTION_DIR := .envs/.production
ENVS_STAGING_DIR := .envs/.staging
TERRAFORM_DIR := terraform

SECRET_VAR_NAME = $(shell echo \
	$(subst /,, $(subst .,_, $(subst terraform/,, $(subst .envs/.,, \
	$(SECRET_FILEPATH)))) | tr '[:lower:]' '[:upper:]'))

ENCODED_SECRET_FILEPATH = $(SECRET_FILEPATH).base64

define ENCODE_AND_SET
$(ENCODED_SECRET_FILEPATH): $(SECRET_FILEPATH)
	base64 $$< > $$@
	gh secret set $(SECRET_VAR_NAME) -r $(REPO) < $$@
endef


SECRET_FILEPATHS := $(ENVS_PRODUCTION_DIR)/.django $(ENVS_PRODUCTION_DIR)/.postgres \
	$(ENVS_PRODUCTION_DIR)/.traefik $(ENVS_STAGING_DIR)/.django \
	$(ENVS_STAGING_DIR)/.traefik $(TERRAFORM_DIR)/staging.tfvars \
	$(TERRAFORM_DIR)/production.tfvars

$(foreach SECRET_FILEPATH, $(SECRET_FILEPATHS), $(eval $(ENCODE_AND_SET)))

all: $(foreach SECRET_FILEPATH, $(SECRET_FILEPATHS), $(ENCODED_SECRET_FILEPATH))

.DEFAULT_GOAL := all
########################################################################################
