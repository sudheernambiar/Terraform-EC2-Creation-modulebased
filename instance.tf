module "VPC" {
    # make sure you have installed git in your instance.
    source = "git::https://github.com/sudheernambiar/Terrafom-vpc-ec2-modulebased.git"
    cidr_block = var.project_cidr
    project    = var.project_name
    level      = var.project_env
    owner      = var.project_owner
    bits       = var.cidr_bits
} 

#create a key pair locally with the name user ssh-keygen and give the keyname as project-key
resource "aws_key_pair" "project-key" {
  key_name   = "project-key"
  public_key = file("project-key.pub")
}

#Security group for bastien
resource "aws_security_group" "bastien" {
  name        = "bastien"
  description = "Allow ssh inbound public"
  vpc_id      = module.VPC.vpc_id

  ingress {
    description      = "ssh from public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-bastien-${var.project_env}"
    Owner = var.project_owner
    Project = var.project_name
    Environment = var.project_env
  }
}
#Security group for webserver
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Allow ssh from bastien 80/443 public"
  vpc_id      = module.VPC.vpc_id

  ingress {
    description      = "ssh from bastien"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [ aws_security_group.bastien.id ]
  }

  ingress {
    description      = "web access from public"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description      = "web access secure from public"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-wordpress-${var.project_env}"
    Owner = var.project_owner
    Project = var.project_name
    Environment = var.project_env
  }
}
#Security group for mysql
resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "Allow ssh from bastien 3306 wordpress"
  vpc_id      = module.VPC.vpc_id

  ingress {
    description      = "ssh from bastien"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [ aws_security_group.bastien.id ]
  }

  ingress {
    description      = "mysql access from wordpress"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [ aws_security_group.webserver.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-mysql-${var.project_env}"
    Owner = var.project_owner
    Project = var.project_name
    Environment = var.project_env
  }
}

#Instance for bastien
resource "aws_instance" "bastien" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.VPC.public_subnet1
  key_name        = "project-key"
  user_data       = "root_enable.sh" 
  vpc_security_group_ids = [ aws_security_group.bastien.id ]
  root_block_device {
    volume_size = 10 
  }
  tags = {
    Name = "${var.project_name}-Basiten-Server-${var.project_env}"
    Owner = var.project_owner
    Project = var.project_name
    Environment = var.project_env
  }
}
#Instance for webserver
resource "aws_instance" "wordpress" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.VPC.public_subnet2
  key_name        = "project-key"
  user_data       = "root_enable.sh" 
  vpc_security_group_ids = [ aws_security_group.webserver.id ]
  root_block_device {
    volume_size = 10 
  }
  tags = {
    Name = "${var.project_name}-Wordpress-Server-${var.project_env}"
    Owner = var.project_owner
    Project = var.project_name
    Environment = var.project_env
  }
}
#instance for mysql
resource "aws_instance" "mysql" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.VPC.private_subnet1
  key_name        = "project-key"
  user_data       = "root_enable.sh" 
  vpc_security_group_ids = [ aws_security_group.mysql.id ]
  root_block_device {
    volume_size = 10 
  }

  tags = {
    Name = "${var.project_name}-MySQL-Server-${var.project_env}"
    Owner = var.project_owner
    Project = var.project_name
    Environment = var.project_env
  }
}

#Output status
# vim output.tf
output "bastion_public_ip" {
    
   value = aws_instance.bastien.public_ip    
}

output "webserver_public_ip" {
   value = aws_instance.wordpress.public_ip  
    
}

output "webserver_private_ip" {
   value = aws_instance.wordpress.private_ip  
    
}

output "database_private_ip" {
  value = aws_instance.mysql.private_ip    
    
}
