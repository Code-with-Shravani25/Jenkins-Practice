# Creating EC2 and locking the state file using backend.tf
resource "aws_instance" "web" {

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "Terraform-EC2"
  }
}
