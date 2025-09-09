# Uncomment the ami datasource to get the AMI id for your ec2 instance:
data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# create a key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
# create an ec2 instance
resource "aws_instance" "instance" {
  ami                         = data.aws_ami.this.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.deployer.key_name
  user_data                   = file("./install-grafana.sh")
  tags = {
    Name = "mate-aws-grafana-lab"
  }
}