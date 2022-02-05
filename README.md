# Terraform-EC2-Creation-modulebased
3 ec2 instance creation with VPC generation backend by passing necessary in variable file.

## Prerequisites
- Script is for AWS environment.
- An EC2 instance with role of admin. 
- Terraform installed.
- Installed with packages tree, git for verification and collection of data.
- cloned all contents in this repo to a single location.

## Files Explained

### Overview
This file contains all necessary to deploy three instances Jump server (ssh public access from anywhere), Web Server(80/443 public access enabled from anywhere & 22 from jump server)  and a MySQL server (privately available, ssh from jump server and MySQL - 3306 port form webserver) which will be in a VPC calling from a module, which is deployed in repo https://github.com/sudheernambiar/Terrafom-vpc-ec2-modulebased.git. 
Module based is a best way to reuse a script which is calling from a the main script with some arguments, and has some return types and some actions of provisioning. Here the module VPC is helping with values passed from the instance.tf and which in turn returns subnet and vpc details for necessary instance creation.

#### Provider.tf
creates the AWS provider in this location with git enabled. (make sure your system is installed with git)

#### variable.tf
Provides with AMI ID of the image you want to pull (here amazon EC2 - need to provide the ID based on region), instance type you can select the one you want to use. This based on instance you can ditch this variable and directly can provide it inside the instance creation part. Root volume size can also be mentioned. Project CIDR value is the value in which we can going to create a VPC with subnets, this will pass to the VPC module. CIDR bits are those bits took from the original CIDR to create those subnets (Say 172.30.0.0/16 and you took 3 bits 172.30.0.0/19 will be the first subnet value). Project name can be the name of your project. Project owner and Environment is as name indicates.

#### instance.tf
Instance file contains a module that links to the git hub repository of the https://github.com/sudheernambiar/Terrafom-vpc-ec2-modulebased.git. If you want it replace with a local location you can also clone them and keep it in a local place where you can provide the source to that directory. Module file contains arguments which we want to pass to the VPC module, where it receives those details mentioned in the variable file. 

You can specify a locally created key file with “ssh-keygen” command and give the name as mentioned in the file or edit the way you want. If you want to keep the one which you have inside the AWS, then this part you can remove and place the key name in key_name in the instance part. Now we have to create three security groups which will help you to limit the traffic to your desired manner. Instances with root volume, where we have specified with instance details, linked with other values. Some values are taking from data sources, which will be coming after the VPC creation. Following are those outputs which we want to use for further procedures, like public IPs and private IPs.
## Execution steps.
- terraform init (to initialise with the provider)
```
$ terraform init 
```
- terraform plan
```
$ terraform plan 
```
- terraform apply (with a yes you can permit after an overview, or explicitly work it with "terraform apply -auto-approve".
```
$ terraform apply 
```
$ terraform apply -auto-approve 
```
Note: In case you want to make a clean-up use "terraform destroy"
## Observations.
- First VPC, Private subnets, Route Tables, NAT GW and IGW will pop up, later instances will be created
- As mentioned, only Jump server may be in accessible way with ssh and rest of them are not accessible from subnet.
- Root user enabled with the script you can disable it if you want.
## Summary
An entire VPC with 6 subnets created to host 3 instances with different characteristics are born. Use case of this can be a word press server. Any edit can be done, as per your requirement.
