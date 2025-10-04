# 🏗️ Terraform AWS Infrastructure Setup

Complete Infrastructure as Code (IaC) setup for deploying the E-Commerce Payment API to AWS.

## 📋 What This Creates

- ✅ **Custom VPC** with public and private subnets across 2 AZs
- ✅ **Internet Gateway** for public internet access
- ✅ **Route Tables** for public and private subnets
- ✅ **Security Groups** with least-privilege access
- ✅ **EC2 Instance** (t3.micro - free tier) with your application
- ✅ **Automated bootstrapping** via user-data script

---

## 🎯 Prerequisites

### 1. Install Terraform

```bash
# macOS
brew install terraform

# Verify installation
terraform --version
```

### 2. Install AWS CLI

```bash
# macOS
brew install awscli

# Verify installation
aws --version
```

### 3. Configure AWS Credentials

```bash
# Configure AWS credentials
aws configure

# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (us-east-1)
# - Default output format (json)

# Verify credentials
aws sts get-caller-identity
```

### 4. Create SSH Key Pair

```bash
# Create SSH key pair in AWS
aws ec2 create-key-pair \
  --key-name my-terraform-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/my-terraform-key.pem

# Set correct permissions
chmod 400 ~/.ssh/my-terraform-key.pem

# Verify
ls -l ~/.ssh/my-terraform-key.pem
```

---

## 🚀 Quick Start

### Step 1: Clone and Setup

```bash
# Create project directory
mkdir terraform-aws-ec2-app
cd terraform-aws-ec2-app

# Create directory structure
mkdir -p modules/{vpc,ec2,security-group}

# Copy all Terraform files to their respective locations
```

###  Update terraform.tfvars

```bash
# Edit terraform.tfvars
nano terraform.tfvars
```
###  Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init

# Verify configuration
terraform validate

# Format code
terraform fmt -recursive
```

###  Plan Infrastructure

```bash
# See what will be created
terraform plan

# Save plan to file
terraform plan -out=tfplan
```

**Expected Output:**
```
Plan: 18 to add, 0 to change, 0 to destroy.
```

### Deploy Infrastructure

```bash
# Apply the plan
terraform apply

# Or apply saved plan
terraform apply tfplan

# Type 'yes' when prompted
```

terraform-aws-ec2-app/
├── main.tf                 # Root module - orchestrates everything
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (customize this!)
├── user_data.sh           # EC2 bootstrap script
├── .gitignore             # Ignore sensitive files
│
├── modules/
│   ├── vpc/               # VPC module
│   │   ├── main.tf        # VPC, subnets, IGW, NAT
│   │   ├── variables.tf   # VPC variables
│   │   └── outputs.tf     # VPC outputs
│   │
│   ├── security-group/    # Security Group module
│   │   ├── main.tf        # SG rules
│   │   ├── variables.tf   # SG variables
│   │   └── outputs.tf     # SG outputs
│   │
│   └── ec2/              # EC2 module
│       ├── main.tf       # EC2 instance, EBS
│       ├── variables.tf  # EC2 variables
│       └── outputs.tf    # EC2 outputs
│
└── terraform.tfstate      # State file (DO NOT COMMIT!)
```

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Region                           │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              VPC (10.0.0.0/16)                         │ │
│  │                                                        │ │
│  │  ┌──────────────────┐      ┌──────────────────┐      │ │
│  │  │  Public Subnet   │      │  Public Subnet   │      │ │
│  │  │  10.0.1.0/24     │      │  10.0.2.0/24     │      │ │
│  │  │  AZ: us-east-1a  │      │  AZ: us-east-1b  │      │ │
│  │  │                  │      │                  │      │ │
│  │  │  ┌────────────┐  │      │                  │      │ │
│  │  │  │ EC2        │  │      │                  │      │ │
│  │  │  │ Instance   │  │      │                  │      │ │
│  │  │  │ t3.micro   │  │      │                  │      │ │
│  │  │  │            │  │      │                  │      │ │
│  │  │  │ :3000      │  │      │                  │      │ │
│  │  │  └────────────┘  │      │                  │      │ │
│  │  └──────────────────┘      └──────────────────┘      │ │
│  │           │                                           │ │
│  │           │                                           │ │
│  │  ┌──────────────────┐      ┌──────────────────┐      │ │
│  │  │ Private Subnet   │      │ Private Subnet   │      │ │
│  │  │  10.0.10.0/24    │      │  10.0.11.0/24    │      │ │
│  │  │  AZ: us-east-1a  │      │  AZ: us-east-1b  │      │ │
│  │  └──────────────────┘      └──────────────────┘      │ │
│  │           │                         │                 │ │
│  │           └─────────┬───────────────┘                 │ │
│  │                     │                                 │ │
│  │              ┌──────▼──────┐                          │ │
│  │              │ NAT Gateway │                          │ │
│  │              └──────┬──────┘                          │ │
│  └─────────────────────┼─────────────────────────────────┘ │
│                        │                                   │
│                 ┌──────▼──────┐                            │
│                 │   Internet  │                            │
│                 │   Gateway   │                            │
│                 └──────┬──────┘                            │
└────────────────────────┼───────────────────────────────────┘
                         │
                         ▼
                    Internet
```

---

## 🔒 Security Best Practices

### Current Security Features:
- ✅ VPC with isolated subnets
- ✅ Security groups with specific port rules
- ✅ NAT Gateway for private subnet internet access
- ✅ No hardcoded credentials

### Recommended Improvements:
- 🔐 Restrict SSH to your IP only
- 🔐 Use AWS Systems Manager Session Manager (no SSH keys)
- 🔐 Enable VPC Flow Logs
- 🔐 Add AWS WAF for web application firewall
- 🔐 Use AWS Secrets Manager for sensitive data
- 🔐 Enable CloudTrail for audit logging

### Update SSH Access to Your IP:

```bash
# Get your public IP
curl ifconfig.me

# Update terraform.tfvars
allowed_ssh_cidr_blocks = ["YOUR_IP/32"]

# Apply changes
terraform apply
```

## 🗑️ Cleanup / Destroy

### Destroy All Resources

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy everything
terraform destroy

# Type 'yes' when prompted
```

**This will delete:**
- ❌ EC2 instance
- ❌ VPC and all subnets
- ❌ Security groups
- ❌ Internet Gateway
- ❌ Route tables

**Warning:** This is irreversible! Make sure you've backed up any data.

---

## 🐛 Troubleshooting

### Terraform Init Fails

```bash
# Clean and reinitialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### User Data Not Running

```bash
# SSH into instance
ssh -i ~/.ssh/my-terraform-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Check logs
sudo cat /var/log/cloud-init-output.log
sudo cat /var/log/user-data.log
```

### Application Not Accessible

```bash
# Check if Docker is running
ssh -i ~/.ssh/my-terraform-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
sudo systemctl status docker

# Check security group
# Make sure port 3000 is open
```

---

## 📚 Learning Resources

### Terraform
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)

### AWS
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)

---

## 🎯 Next Steps

After successful deployment:

1. **Deploy  Application**
   - SSH into the instance
   - Clone your GitHub repo
   - Run your Docker container

2. **Add Domain Name**
   - Register domain with Route 53
   - Create A record pointing to EC2 public IP
   - Set up SSL with Let's Encrypt

3. **Implement CI/CD**
   - GitHub Actions to build Docker image
   - Push to Docker Hub
   - Auto-deploy to EC2

4. **Add Monitoring**
   - CloudWatch alarms
   - Log aggregation
   - Performance metrics

5. **Scale Up**
   - Add Application Load Balancer
   - Implement Auto Scaling Group
   - Add RDS database

---

## 📝 Important Notes

- **State File**: `terraform.tfstate` contains sensitive data - DO NOT commit to Git!
- **Variables**: Never commit `terraform.tfvars` with credentials
- **Keys**: Keep SSH private keys secure
- **Costs**: Remember to destroy resources when done testing

---

## ✅ Checklist

Before running `terraform apply`:
- [ ] AWS credentials configured
- [ ] SSH key pair created
- [ ] `terraform.tfvars` updated with your values
- [ ] Your IP whitelisted for SSH
- [ ] Terraform initialized (`terraform init`)
- [ ] Configuration validated (`terraform validate`)
- [ ] Plan reviewed (`terraform plan`)

---

## 🤝 Contributing

This infrastructure code is part of the DevOps learning journey. Feel free to:
- Suggest improvements
- Report issues
- Add features
- Share your learnings

---

**Built with ❤️ as part of the 30-Day DevOps Challenge**