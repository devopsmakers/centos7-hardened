# centos7-hardened
Configuration for an Oscap PCI-DSS hardened CentOS 7 AMI built using Packer.

# Why
## Overview
As a consultant I work with clients on a range of projects across a range of
business sectors. Currently I'm working with a major InsureTech firm that
produces and runs the software for some of the UK's biggest insurers.

They are a PCI-DSS level 1 merchant and they handle a lot of personally identifiable
data.

## Current AMI's
Currently the CentOS AMI's available in the AWS Market Place are great and certainly
secure enough for general purpose use however they don't have any best practice
or advised security configuration applied.

There is a couple of hardened AMI's available at an extra cost:
CIS CentOS 7: https://aws.amazon.com/marketplace/pp/B01K5TVAOA
OpenLogic Hardened: https://aws.amazon.com/marketplace/pp/B01G7PWQXK

## Community
I wanted to get to grips with building custom OS AMI's in AWS and make it all
open to the wider tech community for free. It was a great learning exercise and
a great opportunity to give a secure OS to the public Marketplace that others can
make use of.

# How
