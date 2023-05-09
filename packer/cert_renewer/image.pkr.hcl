variable "region" {
  type    = string
  default = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "cert_renewer" {
  ami_name      = "cert-renew-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture = "x86_64"
    }

    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.cert_renewer"]
  post-processor "manifest" {}

  provisioner "file" {
    source      = "renew_certificate.py"
    destination = "/tmp/renew_certificate.py"
  }

  provisioner "file" {
    source      = "renew_with_certbot.sh"
    destination = "/tmp/renew_with_certbot.sh"
  }

  provisioner "file" {
    source      = "certbot_token_upload.sh"
    destination = "/tmp/certbot_token_upload.sh"
  }

  provisioner "shell" {
    inline = [
      "pip3 install boto3 pyOpenSSL -q",
      "sudo amazon-linux-extras install epel -y",
      "sudo yum install certbot -y",
      "echo '5 23 * * * python3 /tmp/renew_certificate.py' >> cron", #UTC
      "crontab cron"
    ]
  }
}
