# Terraform Container Odyssey

This project, **Terraform Container Odyssey**, deploys a Docker-based microservices architecture on a DigitalOcean droplet using **Terraform**. The goal is to automate the infrastructure provisioning, application setup, and configuration management using Infrastructure as Code (IaC).

The project extends the concept proposed by [roadmap.sh’s IaC DigitalOcean project](https://roadmap.sh/projects/iac-digitalocean) by adding custom provisioning, network configurations, and dynamic updates.

---

## Objectives
- **Automated Infrastructure Deployment**: Provision a DigitalOcean droplet with Terraform.
- **Custom Application Configuration**: Automate the deployment of a Dockerized application with a Makefile and configuration scripts.
- **Dynamic IP Address Handling**: Update application configurations based on the droplet’s public IP address.
- **SSH Key Integration**: Use SSH keys for secure access and provisioning.

---

## Project Architecture

### Tools and Technologies
- **Terraform**: For infrastructure provisioning.
- **DigitalOcean**: Cloud provider.
- **Docker**: For containerized application deployment.
- **Bash Scripts**: For dynamic IP updates and provisioning tasks.
- **Makefile**: For simplifying application setup and management.

### Components
1. **Terraform Configuration**:
   - Provisions a droplet in the `nyc3` region with a 1GB RAM size (`s-1vcpu-1gb`).
   - Configures SSH access using a pre-existing SSH key.

2. **Provisioners**:
   - **File Provisioner**: Copies configuration files and scripts to the droplet.
   - **Remote-Exec Provisioner**: Executes commands on the droplet to install dependencies and launch the application.

3. **Dynamic IP Configuration**:
   - A script (`domain_ip_modifier.sh`) dynamically updates the application’s `.env` file and Nginx configuration based on the droplet’s public IP.

4. **Outputs**:
   - Exposes the droplet’s public IP address as an output for easy reference.

---

## Folder Structure
```
.
├── provider.tf                # Terraform configuration file
├── conf
│   ├── .env                   # Environment variables for the application
│   ├── domain_ip_modifier.sh  # Script to dynamically update IP configurations
├── output.tf                  # Terraform output definitions
```

---

## Prerequisites
1. **DigitalOcean Account**: Ensure you have an API token.
2. **Terraform**: Install Terraform on your local machine.
3. **SSH Key**: Add your SSH key to DigitalOcean and ensure it’s available locally.

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/your-repo/terraform-container-odyssey.git
cd terraform-container-odyssey
```

### 2. Set Up Environment Variables
Create a file named `.env` in the `conf` directory with the following structure:
```env
SQL_DB=my_database
SQL_USER=my_user
SQL_PASS=my_password
SQL_RPASS=root_password
WP_USER=admin
WP_PASS=admin_password
DOMAIN_NAME=localhost
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Apply Terraform Configuration
Provision the droplet and deploy the application:
```bash
terraform apply
```
Enter `yes` when prompted to confirm.

### 5. Access the Application
- Once the Terraform script completes, the public IP of your droplet will be displayed.
- Access the application via `https://<droplet_ip>`.

---

## Key Features

1. **Dynamic IP Update**:
   - The script `domain_ip_modifier.sh` ensures the droplet’s public IP is automatically updated in the application’s `.env` and Nginx configuration.

2. **File Provisioning**:
   - Environment variables and scripts are transferred to the droplet using Terraform’s file provisioner.

3. **Application Deployment**:
   - The application is cloned from GitHub and set up using `make build` and `make upd`.

4. **Automation**:
   - Dependencies like `make` and Git are installed automatically during provisioning.

---

## Example Terraform Configuration
```hcl
resource "digitalocean_droplet" "container-odyssey" {
  name     = "container-odyssey-droplet"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  image    = "docker-20-04"
  ssh_keys = [data.digitalocean_ssh_key.terraform_ssh_key.id]

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
```

---

## Roadmap
1. Automate SSL certificate installation with Let’s Encrypt.
2. Add monitoring tools like Prometheus and Grafana.
3. Expand infrastructure to include a load balancer and scaling policies.
4. Integrate CI/CD pipelines for seamless application updates.

---

## Acknowledgements
This project was inspired by the [roadmap.sh IaC DigitalOcean project](https://roadmap.sh/projects/iac-digitalocean). Special thanks for their project proposal and structured approach to Infrastructure as Code!

