.PHONY: help
help:
	@echo "Available commands:"
	@echo "	test-env:	Ensure requirements are met for builds to run"
	@echo "	validate:	Validates all packer json configuration files"
	@echo "	test:		Tests environments and validates configuations"
	@echo "	ap-northeast-1:	Build the hardened CentOS 7 AMI in region: ap-northeast-1"
	@echo "	ap-northeast-2:	Build the hardened CentOS 7 AMI in region: ap-northeast-2"
	@echo "	ap-south-1:	Build the hardened CentOS 7 AMI in region: ap-south-1"
	@echo "	ap-southeast-1:	Build the hardened CentOS 7 AMI in region: ap-southeast-1"
	@echo "	ap-southeast-2:	Build the hardened CentOS 7 AMI in region: ap-southeast-2"
	@echo "	ca-central-1:	Build the hardened CentOS 7 AMI in region: ca-central-1"
	@echo "	eu-central-1:	Build the hardened CentOS 7 AMI in region: eu-central-1"
	@echo "	eu-west-1:	Build the hardened CentOS 7 AMI in region: eu-west-1"
	@echo "	eu-west-2:	Build the hardened CentOS 7 AMI in region: eu-west-2"
	@echo "	sa-east-1:	Build the hardened CentOS 7 AMI in region: sa-east-1"
	@echo "	us-east-1:	Build the hardened CentOS 7 AMI in region: us-east-1"
	@echo "	us-east-2:	Build the hardened CentOS 7 AMI in region: us-east-2"
	@echo "	us-west-1:	Build the hardened CentOS 7 AMI in region: us-west-1"
	@echo "	us-west-2:	Build the hardened CentOS 7 AMI in region: us-west-2"
	@echo "	all: 		Build the CentOS 7 hardened AMI for all AWS regions"
	@echo "	help:		This help message"

.PHONY: test-env
test-env:
	@# Searches for required settings as detailed here:
	@# https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials
	@packer version
	@echo "Searching for AWS Credentials... " ; \
	if [ -r "${AWS_SHARED_CREDENTIALS_FILE }" ] ; \
	then \
	  echo "ok [custom credentials file]" ; \
	elif [ -r ~/.aws/credentials ] ; \
	then \
	  echo "ok [user credentials file]" ; \
	elif [ -z "${AWS_ACCESS_KEY_ID}" ] && [ -z "${AWS_ACCESS_KEY}" ] && \
	     [ -z "${AWS_SECRET_ACCESS_KEY}" ] && [ -z "${AWS_SECRET_KEY}" ] ; \
	then \
	  echo "error [no credentials found]" ; \
		exit 1 ; \
	else \
	  echo "ok [environment variables]" ; \
	fi ; \
	echo "Using AWS Profile: " ; [ -z "${AWS_PROFILE}" ] && echo "default" || echo "${AWS_PROFILE}"

.PHONY: validate
validate:
	@for build in packer/*.json; do \
	  echo "Validating $${build}... " ;\
		packer validate $${build} ; \
	done

.PHONY: test
test: test-env validate

.PHONY: build
build: test
	@echo "Building CentOS 7 hardened AMI..."
	packer build -force packer/centos7-hardened.json
