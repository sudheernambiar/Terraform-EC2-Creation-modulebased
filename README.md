# Terraform-EC2-Creation-modulebased
3 ec2 instance creation with VPC generation backend by passing necessary in variable file.

## Prerequisites
Script is for AWS environment.

An EC2 instance with role of admin. 

Terraform installed.

Installed with packages tree, git for verification and collection of data.

cloned all contents in this repo to a single location.

## Files Explained

### Overview
This file contains all necessary to deploy three instances Jump server(ssh public access from anywhere), Web Server(80/443 public access enabled from anywhere & 22 from jump server)  and a mysql server (privately available, ssh from jump server and mysql - 3306 port form webserver) which will be in a VPC calling from a module, which is deployed in repo https://github.com/sudheernambiar/Terrafom-vpc-ec2-modulebased.git. 
Module based is a best way to reuse a script which is calling from a the main script with some arguements, and has some return types and some actions of provisioning. Here the module VPC is helping with values passed from the instance.tf and which inturn returns subnet and vpc details for necessary instance creation.

#### Provider.tf
creates the AWS provider in this location with git enabled.(make sure your system is installed with git)

#### variable.tf
Provides with AMI ID of the image you want to pull(here amazon EC2 - need to provide the ID based on region), instance type you can select the one you want to use. This based on in stance you can ditch this variable and directly can provide it inside the instance creation part. Project CIDR value is the value in which we can going to create a VPC with subnets, this will pass to the VPC module. CIDR bits are those bits took from the original CIDR to create those subnets (Say 172.30.0.0/16 and you took 3 bits 172.30.0.0/19 will be the first subnet value)

#### instance.tf
