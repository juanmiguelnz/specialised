data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web" {
  count                       = local.web_instance_count
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnets[count.index].id
  associate_public_ip_address = true
  key_name                    = var.instance_key
  vpc_security_group_ids      = [aws_security_group.public_instances.id]

  tags = {
    Name = "${local.tags.prefix}-${count.index}"
  }
}

resource "aws_instance" "backend" {
  count                  = local.backend_instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnets[count.index].id
  key_name               = var.instance_key
  vpc_security_group_ids = [aws_security_group.private_instances.id]

  tags = {
    Name = "${local.tags.prefix}-${count.index}"
  }
}