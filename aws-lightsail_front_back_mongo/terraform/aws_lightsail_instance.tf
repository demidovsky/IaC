resource "aws_lightsail_key_pair" "my_key_pair" {
  name = "my_key_pair"
}

resource "aws_lightsail_instance" "my_instance" {
  depends_on = [aws_lightsail_key_pair.my_key_pair]
  name              = "MyInstance"
  availability_zone = "us-central-1a"
  blueprint_id      = "ubuntu_20_04"
  bundle_id         = "micro_2_0"
  key_pair_name     = aws_lightsail_key_pair.my_key_pair.name
  tags              = {
    frontend = "my-frontend"
    backend = "my-backend"
    db = "mongo"
  }
  # user_data         = "sudo yum install -y httpd && sudo systemctl start httpd && sudo systemctl enable httpd && echo '<h1>Deployed via Terraform</h1>' | sudo tee /var/www/html/index.html"
}

output "instance_ip" {
  description = "IP of created instance"
  value       = aws_lightsail_instance.my_instance.public_ip_address
}

output "public_key" {
  description = "Content of the generated public key"
  value       = aws_lightsail_key_pair.my_key_pair.public_key
}

output "private_key" {
  description = "Content of the generated private key"
  value       = aws_lightsail_key_pair.my_key_pair.private_key
}