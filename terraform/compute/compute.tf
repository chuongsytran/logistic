// Tạo 1 instance type ami của provider aws đặt tên local là ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]

  }
}

data "terraform_remote_state" "network_logistic" {
  backend = "s3"
  config = {
    bucket = "chuong-logistic-bucket"
    key    = "logistic/dev/network/terraform.tfstate"
    region = var.aws_region
  }
}

// Tạo 1 security group của aws đặt tên local là logistic_sg
resource "aws_security_group" "logistic_sg" {
  name        = "logistic-security-group"
  description = "Securiry rules for Logistic application"
  vpc_id      = data.terraform_remote_state.network_logistic.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.241.227.54/32"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22"
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "173.245.48.0/20",
      "103.21.244.0/22",
      "103.22.200.0/22",
      "103.31.4.0/22",
      "141.101.64.0/18",
      "108.162.192.0/18",
      "190.93.240.0/20",
      "188.114.96.0/20",
      "197.234.240.0/22",
      "198.41.128.0/17",
      "162.158.0.0/15",
      "104.16.0.0/13",
      "104.24.0.0/14",
      "172.64.0.0/13",
      "131.0.72.0/22"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "logistic_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.aws_instance_type
  key_name      = var.aws_logistic_key
  subnet_id     = data.terraform_remote_state.network_logistic.outputs.public_subnet_id_1a

  vpc_security_group_ids = [aws_security_group.logistic_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "Logistic-Production-Node"
  }
  # trigger: aws_instance.logistic_server biến mất khỏi state (0 instance trên AWS
  # thực tế) — cần terraform apply để tạo lại. paths: terraform/** của infrastructure.yml
  # chỉ trigger khi có thay đổi trong thư mục này.

  # Ép Terraform tự động xóa EC2 cũ và tạo EC2 mới mỗi khi đoạn script user_data bên dưới bị sửa
  user_data_replace_on_change = true

  user_data = file("${path.module}/scripts/setup-podman.sh")

}
