resource "aws_instance" "jenkin-ec3" {
  ami           = data.aws_ami.example.id
  instance_type = var.instance_type
  key_name      = "project-killi"

  vpc_security_group_ids = [aws_security_group.jenkins-ec2.id]
  subnet_id              = module.vpc.public_subnets[0]

  user_data              = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y
java -version

sudo apt-get update -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y

sudo apt-get install jenkins -y



EOF


}
