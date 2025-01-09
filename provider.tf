terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 1.0"
    }
  }
  required_version = "~> 1.0"
}

variable "do_token" {
  type        = string
  default     = null
  description = "DigitalOcean API token"
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform_ssh_key" {
  name = "pro_gmail"
}

resource "digitalocean_droplet" "container-odyssey" {
  name     = "container-odyssey-droplet"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  image    = "docker-20-04"
  ssh_keys = [data.digitalocean_ssh_key.terraform_ssh_key.id]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_ed25519_pro_gmail")
    host        = self.ipv4_address
  }

  provisioner "file" {
    source      = "conf/.env"
    destination = "/opt/.env"
  }

  provisioner "file" {
    source      = "./conf/domain_ip_modifier.sh"
    destination = "/opt/domain_ip_modifier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "apt install make",
      "git config --global user.name 'dummy'",
      "git config --global user.email 'dummy@exemple.com'",
      "git clone https://github.com/M-Boiguille/container_odyssey.git /opt/container-odyssey",
      "mv /opt/.env /opt/container-odyssey/srcs/",
      "cd /opt/ && bash domain_ip_modifier.sh",
      "cd /opt/container-odyssey && make build && make upd"
    ]
  }
}

output "droplet_ip" {
  value = digitalocean_droplet.container-odyssey.ipv4_address
}

