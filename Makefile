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

.PHONY: ap-northeast-1
ap-northeast-1: test
	@echo "Building AMI in ap-northeast-1..."
	packer build -only=ap-northeast-1 -force packer/centos7-hardened.json

.PHONY: ap-northeast-2
ap-northeast-2: test
	@echo "Building AMI in ap-northeast-2..."
	packer build -only=ap-northeast-2 -force packer/centos7-hardened.json

.PHONY: ap-south-1
ap-south-1: test
	@echo "Building AMI in ap-south-1..."
	packer build -only=ap-south-1 -force packer/centos7-hardened.json

.PHONY: ap-southeast-1
ap-southeast-1: test
	@echo "Building AMI in ap-southeast-1..."
	packer build -only=ap-southeast-1 -force packer/centos7-hardened.json

.PHONY: ap-southeast-2
ap-southeast-2: test
	@echo "Building AMI in ap-southeast-2..."
	packer build -only=ap-southeast-2 -force packer/centos7-hardened.json

.PHONY: ca-central-1
ca-central-1: test
	@echo "Building AMI in ca-central-1..."
	packer build -only=ca-central-1 -force packer/centos7-hardened.json

.PHONY: eu-central-1
eu-central-1: test
	@echo "Building AMI in eu-central-1..."
	packer build -only=eu-central-1 -force packer/centos7-hardened.json

.PHONY: eu-west-1
eu-west-1: test
	@echo "Building AMI in eu-west-1..."
	packer build -only=eu-west-1 -force packer/centos7-hardened.json

.PHONY: eu-west-2
eu-west-2: test
	@echo "Building AMI in eu-west-2..."
	packer build -only=eu-west-2 -force packer/centos7-hardened.json

.PHONY: sa-east-1
sa-east-1: test
	@echo "Building AMI in sa-east-1..."
	packer build -only=sa-east-1 -force packer/centos7-hardened.json

.PHONY: us-east-1
us-east-1: test
	@echo "Building AMI in us-east-1..."
	packer build -only=us-east-1 -force packer/centos7-hardened.json

.PHONY: us-east-2
us-east-2: test
	@echo "Building AMI in us-east-2..."
	packer build -only=us-east-2 -force packer/centos7-hardened.json

.PHONY: us-west-1
us-west-1: test
	@echo "Building AMI in us-west-1..."
	packer build -only=us-west-1 -force packer/centos7-hardened.json

.PHONY: us-west-2
us-west-2: test
	@echo "Building AMI in us-west-2..."
	packer build -only=us-west-2 -force packer/centos7-hardened.json

.PHONY: all
all: test
	@echo "Building all AMIs..."
	packer build -force packer/centos7-hardened.json
