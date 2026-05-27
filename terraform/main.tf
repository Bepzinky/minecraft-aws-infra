provider "aws" {
  region = var.region
}

data "aws_vpc" "default" { default = true }

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "minecraft" {
  name        = "minecraft-sg"
  description = "SSH restricted to admin IP; Minecraft port open to all clients"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH admin access from operator IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Minecraft client connections"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound for ECR pull and S3 access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = "mc-server-3" }
}

resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.minecraft]
  triggers   = { instance_id = aws_instance.minecraft.id }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60s for SSH to come up..."
      sleep 60
      ansible-playbook \
        -i '${aws_instance.minecraft.public_ip},' \
        --private-key ~/312ssh/cs312-key.pem \
        -u ec2-user \
        --ssh-extra-args='-o StrictHostKeyChecking=no' \
        -e ecr_repo_url=${var.ecr_repo_url} \
        -e s3_bucket=${var.s3_bucket} \
        ../ansible/playbook.yml
    EOT
  }
}
