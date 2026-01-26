# StartTech Infrastructure - Complete DevOps CI/CD Pipeline

**Student:** Baribefe Gbara  
**Student ID:** ALT/SOE/025/0985  
**Project:** Full-Stack Application Deployment with AWS, Terraform, and Docker  
**Submission Date:** January 26, 2026

---

## Project Overview

This project demonstrates a production-ready CI/CD pipeline for a full-stack Todo application, showcasing Infrastructure as Code (IaC), containerization, automated deployment, and comprehensive monitoring on AWS.

### Key Components

- Complete AWS Infrastructure (41 resources deployed)
- Frontend Deployment to S3 with static website hosting
- Backend Deployment on EC2 with Auto Scaling
- Database using MongoDB Atlas
- Caching with ElastiCache Redis
- Load Balancing with Classic ELB
- Monitoring with CloudWatch (logs, alarms, dashboard)
- Infrastructure as Code with Terraform modules
- Containerization with Docker
- CI/CD Pipelines with GitHub Actions

---

## Live Application

**Frontend (React):** http://starttech-production-frontend-11dizw0h.s3-website-us-east-1.amazonaws.com  
**Backend API (Golang):** http://starttech-production-elb-405213049.us-east-1.elb.amazonaws.com  
**Status:** Fully operational with 2/2 instances InService

---

## Architecture

### High-Level Overview
```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    VPC (10.0.0.0/16)                 │    │
│  │                                                       │    │
│  │  ┌──────────────┐         ┌──────────────┐          │    │
│  │  │ Public Subnet│         │ Public Subnet│          │    │
│  │  │  us-east-1a  │         │  us-east-1b  │          │    │
│  │  │              │         │              │          │    │
│  │  │     ELB      │◄────────┤     ELB      │          │    │
│  │  └──────┬───────┘         └──────────────┘          │    │
│  │         │                                            │    │
│  │  ┌──────▼───────┐         ┌──────────────┐          │    │
│  │  │Private Subnet│         │Private Subnet│          │    │
│  │  │  us-east-1a  │         │  us-east-1b  │          │    │
│  │  │              │         │              │          │    │
│  │  │ EC2 Backend  │         │ EC2 Backend  │          │    │
│  │  │   (Docker)   │         │   (Docker)   │          │    │
│  │  └──────┬───────┘         └──────┬───────┘          │    │
│  │         │                        │                   │    │
│  │         └────────┬───────────────┘                   │    │
│  │                  │                                    │    │
│  │         ┌────────▼────────┐                          │    │
│  │         │ ElastiCache     │                          │    │
│  │         │ Redis (Cache)   │                          │    │
│  │         └─────────────────┘                          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌─────────────────┐           ┌──────────────────┐         │
│  │  S3 Bucket      │           │   CloudWatch     │         │
│  │  (Frontend)     │           │   (Monitoring)   │         │
│  └─────────────────┘           └──────────────────┘         │
└─────────────────────────────────────────────────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  MongoDB Atlas  │
              │   (Database)    │
              └─────────────────┘
```

### Network Configuration

**VPC:**
- CIDR Block: 10.0.0.0/16
- Availability Zones: us-east-1a, us-east-1b
- DNS Hostnames and Resolution: Enabled

**Subnets:**
- Public Subnet 1: 10.0.1.0/24 (us-east-1a)
- Public Subnet 2: 10.0.2.0/24 (us-east-1b)
- Private Subnet 1: 10.0.11.0/24 (us-east-1a)
- Private Subnet 2: 10.0.12.0/24 (us-east-1b)

**Connectivity:**
- Internet Gateway for public subnets
- NAT Gateway for private subnet internet access
- S3 VPC Endpoint for cost-efficient S3 access

**Design Rationale:**
- High Availability through Multi-AZ deployment
- Enhanced Security with backend in private subnets
- Scalability via Auto Scaling Group
- Cost Optimization using S3 VPC Endpoint
- Improved Performance with Redis caching

---

## Repository Structure
```
StartTech-infra-Baribefe-0985/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── modules/
│       ├── networking/
│       ├── storage/
│       ├── compute/
│       └── monitoring/
├── scripts/
│   ├── setup-backend.sh
│   └── deploy-to-ec2.sh
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml
├── monitoring/
│   ├── cloudwatch-dashboard.json
│   ├── alarm-definitions.json
│   └── log-insights-queries.txt
├── README.md
├── ARCHITECTURE.md
└── RUNBOOK.md
```

---

## Getting Started

### Prerequisites

- AWS CLI v2+
- Terraform v1.9+
- Git
- AWS account with appropriate IAM permissions

### Setup Instructions

#### 1. Clone Repository
```bash
git clone https://github.com/BaribefeGbara/StartTech-infra-Baribefe-0985.git
cd StartTech-infra-Baribefe-0985
```

#### 2. Configure AWS CLI
```bash
aws configure
aws sts get-caller-identity  # Verify configuration
```

#### 3. Create Terraform Backend
```bash
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh
```

This creates an S3 bucket for state storage and a DynamoDB table for state locking.

#### 4. Configure Backend

Edit `terraform/backend.tf` with your bucket name from the previous step.

#### 5. Set Up MongoDB Atlas

1. Create free M0 cluster at mongodb.com/cloud/atlas
2. Configure database user and network access
3. Obtain connection string

#### 6. Configure Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your values
```

---

## Deployment

### Deploy Infrastructure
```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

Deployment takes approximately 10-15 minutes. Review the plan carefully before applying.

### View Outputs
```bash
terraform output
```

Important outputs include:
- backend_elb_dns
- frontend_bucket_name
- vpc_id

---

## Testing & Verification

### Verify Infrastructure
```bash
# List all resources
terraform state list

# Check EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=starttech-production-backend" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table

# Verify load balancer health
aws elb describe-instance-health \
  --load-balancer-name starttech-production-elb
```

### Test Application
```bash
# Test backend health
curl http://starttech-production-elb-405213049.us-east-1.elb.amazonaws.com/health

# Access frontend
# Visit: http://starttech-production-frontend-11dizw0h.s3-website-us-east-1.amazonaws.com
```

---

## Operations & Maintenance

### Common Operations
```bash
# View infrastructure state
terraform state list
terraform output

# Update infrastructure
terraform plan
terraform apply

# Destroy infrastructure
terraform destroy
```

### Monitoring
```bash
# View logs in real-time
aws logs tail /aws/ec2/starttech-production-backend --follow

# Check alarms
aws cloudwatch describe-alarms --alarm-name-prefix starttech-production
```

### Scaling

Modify `backend_desired_capacity` in `terraform/variables.tf` and apply changes:
```bash
terraform apply
```

---

## Troubleshooting

### Instances Show OutOfService

**Diagnosis:**
```bash
aws elb describe-instance-health --load-balancer-name starttech-production-elb
```

**Common causes:**
- Instances still initializing (wait 10-15 minutes)
- Application not running on port 8080
- Health check endpoint unavailable
- Security group misconfiguration

**Resolution:**
Check CloudWatch logs and verify security group rules allow traffic on port 8080.

### Terraform State Locked
```bash
# Force unlock (use LockID from error message)
terraform force-unlock LOCK-ID
```

### MongoDB Connection Issues

Verify:
- IP whitelist in MongoDB Atlas includes 0.0.0.0/0 or specific EC2 IPs
- Connection string format is correct
- Security groups allow outbound traffic on port 27017

---

## Cost Management

### Monthly Cost Estimate

| Resource | Type | Estimated Cost |
|----------|------|----------------|
| NAT Gateway | Standard | ~$32/month |
| ElastiCache Redis | t3.micro | ~$25/month |
| EC2 Instances | 2x t3.micro | FREE (or ~$15/month) |
| S3 Storage | <5GB | FREE |
| Data Transfer | Minimal | ~$1/month |
| **Total** | | **~$58-60/month** |

### Cost Optimization

1. Use S3 VPC Endpoint (implemented) to reduce NAT Gateway costs
2. Leverage EC2 free tier (750 hours/month for 12 months)
3. Destroy infrastructure during non-use periods
4. Set up billing alerts
5. Right-size instances based on actual usage
```bash
# Set up billing alarm
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

---

## Security

### Implemented Measures

- Network isolation with private subnets
- Security groups configured as firewalls
- IAM roles for EC2 instances (no hardcoded credentials)
- Encrypted Terraform state in S3
- GitHub Secrets for sensitive data
- TLS for MongoDB connections

### Recommendations

1. Restrict security group rules to specific IP ranges
2. Enable MFA on AWS accounts
3. Rotate access keys every 90 days
4. Enable AWS CloudTrail for audit logging
5. Use AWS Secrets Manager for sensitive data

---

## Additional Resources

- [Complete Architecture Guide](./ARCHITECTURE.md)
- [Operations Runbook](./RUNBOOK.md)
- Application Repository: [StartTech-Baribefe-0985](https://github.com/BaribefeGbara/StartTech-Baribefe-0985)

### Learning Resources

- [AWS Documentation](https://docs.aws.amazon.com)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices)

---

## Author

**Baribefe Gbara**  
DevOps Engineering Student - AltSchool Africa  
Student ID: ALT/SOE/025/0985

**Contact:**
- Email: gbarabaribefe@gmail.com
- GitHub: [@BaribefeGbara](https://github.com/BaribefeGbara)

---

## Acknowledgments

- AltSchool Africa for comprehensive DevOps training
- AWS for Free Tier and documentation
- The DevOps community for valuable resources

---

## Project Timeline

- **Duration:** 3 days (January 24-26, 2026)
- **Time Invested:** 40+ hours

---

*Last Updated: January 26, 2026*# CI/CD Enabled
