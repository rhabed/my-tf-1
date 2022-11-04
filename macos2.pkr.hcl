variable "ami_name" {
  type    = string
  default = "anzx-macos-ami"
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "root_volume_size_gb" {
  type    = number
  default = 150
}

variable "http_proxy_host" {
  type    = string
  default = "172.31.3.244"
}

variable "http_proxy_port" {
  type    = string
  default = "3128"
}

variable "kms_key_id" {
  type    = string
  default = "5136c1e7-df6b-461a-be44-46de278bc52e"
  #12ab34cd-12ab-34cd-56ef-123abc456def"
}

variable "proxy_secret_arn" {
  type    = string
  default = "anzx_proxy_secret_arn"
}

data "amazon-secretsmanager" "proxy_username" {
  name = "${var.proxy_secret_arn}"
  key  = "username"
}

data "amazon-secretsmanager" "proxy_password" {
  name = "${var.proxy_secret_arn}"
  key  = "password"
}

locals {
  username_secret_value = jsondecode(data.amazon-secretsmanager.proxy_username.secret_string)["username"]
  password_secret_value = jsondecode(data.amazon-secretsmanager.proxy_password.secret_string)["password"]
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "mac-image-builder" {
  ami_name                = "${var.ami_name}-${local.timestamp}"
  ami_virtualization_type = "hvm"
  ssh_username            = "ec2-user"
  ssh_timeout             = "2h"
  placement {
    tenancy = "host"
  }
  ebs_optimized = true
  instance_type = "mac1.metal"
  region        = "ap-southeast-2"
  subnet_id     = "${var.subnet_id}"
  encrypt_boot  = true
  kms_key_id    = "${var.kms_key_id}"

  aws_polling {
    delay_seconds = 60
    max_attempts  = 60
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "${var.root_volume_size_gb}"
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }
  source_ami_filter {
    filters = {
      name                = "amzn-ec2-macos-12.*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
}

build {
  sources = ["source.amazon-ebs.mac-image-builder"]

  # resize the partition to use all the space available on the EBS volume
  provisioner "shell" {
    inline = [
      "PDISK=$(diskutil list physical external | head -n1 | cut -d' ' -f1)",
      "APFSCONT=$(diskutil list physical external | grep Apple_APFS | tr -s ' ' | cut -d' ' -f8)",
      "yes | sudo diskutil repairDisk $PDISK",
      "sudo diskutil apfs resizeContainer $APFSCONT 0"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo /usr/local/bin/ec2-macos-init clean --all"
    ]
  }
#   provisioner "file" {
#     source      = "/home/ec2-user/cloudwatch/macos_cloudwatch.json"
#     destination = "/Users/ec2-user/macos_cloudwatch.json"
#   }

#    provisioner "file" {
#     source      = "/home/ec2-user/scripts/agents.sh"
#     destination = "/Users/ec2-user/agents.sh"
#   }

  ## Setting Proxy for ec2-user and root
  provisioner "shell" {
    inline = [
      "echo Start Proxy configuration",
      "proxy_host=${var.http_proxy_host}",
      "proxy_port=${var.http_proxy_port}",
      "PROXY=http://$proxy_host:$proxy_port",
      "echo export http_proxy=$PROXY >> $HOME/.profile",
      "echo export HTTP_PROXY=$PROXY >> $HOME/.profile",
      "echo export https_proxy=$PROXY>> $HOME/.profile",
      "echo export HTTPS_PROXY=$PROXY >> $HOME/.profile",
      "echo export NO_PROXY=127.0.0.1,localhost,169.254.169.253,169.254.169.254,169.254.170.2,s3-ap-southeast-2.amazonaws.com,s3.ap-southeast-2.amazonaws.com,s3.dualstack.ap-southeast-2.amazonaws.com,.cpaas.test,.gcp.anz,.gcpnp.anz,.k8s.gcpnp.anz,.service.anz,.service.dev,pkitestcrl01.svc.np.au1.aws.anz.com,puppetmaster.svc.np.au1.aws.anz.com,vault-dev.smp.np.au1.aws.anz.com,vault-np.smp.np.au1.aws.anz.com,comprehend.ap-southeast-2.amazonaws.com,ebs.ap-southeast-2.amazonaws.com,ec2.ap-southeast-2.amazonaws.com,ec2messages.ap-southeast-2.amazonaws.com,elasticbeanstalk.ap-southeast-2.amazonaws.com,elasticfilesystem.ap-southeast-2.amazonaws.com,events.ap-southeast-2.amazonaws.com,kms.ap-southeast-2.amazonaws.com,lambda.ap-southeast-2.amazonaws.com,logs.ap-southeast-2.amazonaws.com,mgn.ap-southeast-2.amazonaws.com,monitoring.ap-southeast-2.amazonaws.com,rds.ap-southeast-2.amazonaws.com,secretsmanager.ap-southeast-2.amazonaws.com,ssm.ap-southeast-2.amazonaws.com,ssmmessages.ap-southeast-2.amazonaws.com,states.ap-southeast-2.amazonaws.com,sts.ap-southeast-2.amazonaws.com,textract.ap-southeast-2.amazonaws.com,xray.ap-southeast-2.amazonaws.com,sqs.ap-southeast-2.amazonaws.com >> $HOME/.profile",
      "echo export no_proxy=127.0.0.1,localhost,169.254.169.253,169.254.169.254,169.254.170.2,s3-ap-southeast-2.amazonaws.com,s3.ap-southeast-2.amazonaws.com,s3.dualstack.ap-southeast-2.amazonaws.com,.cpaas.test,.gcp.anz,.gcpnp.anz,.k8s.gcpnp.anz,.service.anz,.service.dev,pkitestcrl01.svc.np.au1.aws.anz.com,puppetmaster.svc.np.au1.aws.anz.com,vault-dev.smp.np.au1.aws.anz.com,vault-np.smp.np.au1.aws.anz.com,comprehend.ap-southeast-2.amazonaws.com,ebs.ap-southeast-2.amazonaws.com,ec2.ap-southeast-2.amazonaws.com,ec2messages.ap-southeast-2.amazonaws.com,elasticbeanstalk.ap-southeast-2.amazonaws.com,elasticfilesystem.ap-southeast-2.amazonaws.com,events.ap-southeast-2.amazonaws.com,kms.ap-southeast-2.amazonaws.com,lambda.ap-southeast-2.amazonaws.com,logs.ap-southeast-2.amazonaws.com,mgn.ap-southeast-2.amazonaws.com,monitoring.ap-southeast-2.amazonaws.com,rds.ap-southeast-2.amazonaws.com,secretsmanager.ap-southeast-2.amazonaws.com,ssm.ap-southeast-2.amazonaws.com,ssmmessages.ap-southeast-2.amazonaws.com,states.ap-southeast-2.amazonaws.com,sts.ap-southeast-2.amazonaws.com,textract.ap-southeast-2.amazonaws.com,xray.ap-southeast-2.amazonaws.com,sqs.ap-southeast-2.amazonaws.com >> $HOME/.profile",
      "echo source $HOME/.profile >> $HOME/.zshrc",
      "cat $HOME/.zshrc",
      "sudo cp $HOME/.profile /var/root",
      "exit",
      "echo Finish Proxy configuration",
    ]
  }


  ## install cloudwatch agent
#   provisioner "shell" {
#     inline = [
#       "pushd /tmp",
#       "echo Start Downloading Amazon Cloudwatch Agent",
#       "export SVC_PROXY=http://proxy.svc.np.au1.aws.anz.com:3128",
#       "curl -x $SVC_PROXY -Lo amazon-cloudwatch-agent.pkg https://s3.amazonaws.com/amazoncloudwatch-agent/darwin/amd64/latest/amazon-cloudwatch-agent.pkg",
#       "ls -ltr | grep amazon-cloudwatch-agent.pkg",
#       "echo Start Installing Amazon Cloudwatch Agent",
#       "sudo installer -pkg /tmp/amazon-cloudwatch-agent.pkg -target /",
#       "sudo mv /Users/ec2-user/macos_cloudwatch.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",
#       "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s",
#       "echo Done Installing Amazon Cloudwatch Agent",
#       "popd"
#     ]
#   }

  provisioner "shell" {
    inline = [
      "echo SOFTWARE UPDATE",
      "source $HOME/.profile",
      "echo $HTTP_PROXY",   
      "curl -x $HTTP_PROXY -o sucatalg1.gz  https://swscan.apple.com/content/catalogs/others/index-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz --verbose",
      "curl -o sucatalg2.gz  https://swscan.apple.com/content/catalogs/others/index-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz --verbose",
      "sudo softwareupdate -i -a",
      "sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true",
      "sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE",
      "sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true",
      "sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true",
      "sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool TRUE",
      "echo Finish Software Update",
      "exit"
    ]
  }
  provisioner "shell" {
    inline = [
      "echo BREW UPDATE",
      "source $HOME/.profile",
      "echo $HTTP_PROXY",
      "curl -x $HTTP_PROXY -o sucatalg3.gz  https://swscan.apple.com/content/catalogs/others/index-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz --verbose",
      "curl -o sucatalg4.gz  https://swscan.apple.com/content/catalogs/others/index-12-10.16-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz --verbose",
      "export HOMEBREW_ARTIFACT_DOMAIN=https://artifactory.gcp.anz/artifactory/homebrew",
      "/usr/local/bin/brew update",
      "/usr/local/bin/brew upgrade",
      "/usr/local/bin/brew install gh",
      "/usr/local/bin/brew install jq",
      "/usr/local/bin/brew install robotsandpencils/made/xcodes",
      "echo Finish Brew Update",
      "echo Start Agents Installation",
      "cd /Users/ec2-user",
      "chmod +x agents.sh",
      "sudo ./agents.sh",
      "echo finsh Agents Installation"
    ]
  }
  ## Add ANZ Certificates
  ## Pending adding certs to s3 Buckets
  // provisioner "file" {
  //   generated   = true
  //   destination = "/opt/soe/"
  //   sources = [
  //     "/home/ec2-user/config/certs/ANZ NZ Issuing CA 01.pem",
  //     "/home/ec2-user/config/certs/ANZ NZ Issuing CA 02.pem",
  //     "/home/ec2-user/config/certs/ANZ NZ Root CA.pem",
  //     "/home/ec2-user/config/certs/ANZ NZ Test Issuing CA 01.pem",
  //     "/home/ec2-user/config/certs/ANZ NZ Test Issuing CA 02.pem",
  //     "/home/ec2-user/config/certs/ANZ NZ Test Root CA.pem",
  //     "/home/ec2-user/config/certs/ANZ_GlobalTest_CA_01_v3.pem",
  //     "/home/ec2-user/config/certs/ANZ_GlobalTest_CA_02_v3.pem",
  //     "/home/ec2-user/config/certs/ANZ_GlobalTest_Root_CA_v3.pem",
  //     "/home/ec2-user/config/certs/ANZ_Global_Root_CA_v2.pem",
  //     "/home/ec2-user/config/certs/ANZ_Global_CA_01_v2.pem",
  //     "/home/ec2-user/config/certs/ANZ_Global_CA_02_v2.pem",
  //   ]
  // }

  // provisioner "shell" {
  //   execute_command = "sudo -S env {{ .Vars }} bash {{ .Path }}"
  //   inline          = ["mv /opt/soe/ANZ*.pem /home/ec2-user/config/certs/", "update-ca-trust"]
  // }

  // provisioner "shell" {
  //   inline = [
  //     "echo Checking proxy Settings",
  //     "sudo echo $HTTP_PROXY",
  //     "echo bash proxy.sh",
  //     "sudo bash ~/proxy.sh",
  //     "sudo echo $HTTP_PROXY",      

  //   ]
  // }
  // provisioner "shell" {
  //   inline = [
  //     "export HOMEBREW_ARTIFACT_DOMAIN=https://artifactory.gcp.anz/artifactory/homebrew",
  //     "echo Checking proxy Settings",
  //     "echo $HTTP_PROXY",
  //     "echo bash proxy.sh",
  //     "sudo bash ~/proxy.sh",
  //     "sudo echo $HTTP_PROXY",     
  //     "softwareupdate -i -a",

  //   ]
  // }

#   provisioner "file" {
#     source      = "/home/ec2-user/scripts/hardening.sh"
#     destination = "/Users/ec2-user/hardening.sh"
#   }

#   provisioner "shell" {
#     inline = [
#       "cd /Users/ec2-users",
#       "chmod +x hardening.sh",
#       "sudo ./hardening.sh",
#     ]
#   }



  // provisioner "shell" {
  //   inline = [

  //   ]
  // }
}