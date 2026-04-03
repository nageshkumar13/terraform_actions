data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  count = var.ami_id == "" ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

locals {
  repo_root       = "${path.module}/.."
  selected_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.amazon_linux_2023_ami[0].value

  tracked_app_files = sort(concat(
    tolist(fileset(local.repo_root, "app/**")),
    tolist(fileset(local.repo_root, "Dockerfile")),
    tolist(fileset(local.repo_root, "requirements.txt"))
  ))

  app_source_digest = sha256(join("", [
    for file_path in local.tracked_app_files :
    filesha256("${local.repo_root}/${file_path}")
  ]))
}

resource "aws_security_group" "app_sg" {
  name_prefix = "${var.security_group_name}-"
  description = "Allow browser access to the containerized FastAPI app"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.host_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = [var.http_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = var.security_group_name
    },
    var.tags
  )
}

resource "aws_instance" "app_server" {
  ami                         = local.selected_ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    app_directory  = var.app_directory
    container_name = var.container_name
    container_port = var.container_port
    host_port      = var.host_port
    repo_branch    = var.repo_branch
    repo_url       = var.repo_url
    source_digest  = local.app_source_digest
  })

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}
