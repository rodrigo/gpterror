variable "region" {
  type    = string
  default = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "gpterror" {
  ami_name      = "gpterror-${local.timestamp}"
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
  sources = ["source.amazon-ebs.gpterror"]
  post-processor "manifest" {}

  provisioner "file" {
    source      = "generate_and_upload_text.sh"
    destination = "/tmp/generate_and_upload_text.sh"
  }

  provisioner "shell" {
    inline = [
      "echo '* * * * * sh /tmp/generate_and_upload_text.sh' >> cron",
      "crontab cron"
    ]
  }
}
