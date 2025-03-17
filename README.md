# 🚀 Cloud Infrastructure Engineer Challenge

Welcome to the **Cloud Infrastructure Engineer Challenge!** 🎉 This challenge is designed to evaluate your ability to work with **Infrastructure as Code (IaC)**, AWS networking, IAM, and automation using modern DevOps practices.

You will deploy a small AWS architecture using **any IaC tool of your choice** (Terraform preferred, but alternatives are allowed). If you choose a different tool or a combination of tools, **justify your decision!** 💡

## ⚡ Challenge Overview

Your task is to deploy the following infrastructure on AWS:

✅ **An API Gateway** with a single endpoint (`GET /info`).
✅ **A Lambda function** triggered by the API Gateway.
✅ **A database instance or application backend** running in a private subnet. This can be:

- A **PostgreSQL RDS instance** 📦
- A **self-hosted database** on an EC2 instance 🔗
- A **deployed application** such as WordPress hosted on EC2 🎨
✅ **The Lambda function must connect** to the database/backend and return basic information about its connection and status.
✅ **Logs from the Lambda** should be visible in CloudWatch 📊
✅ **Networking must include:** VPC, public/private subnets, and security groups.
✅ **The Lambda must be in a private subnet** and use a NAT Gateway in a public subnet for internet access 🌍

## 📌 Requirements

### 🛠 Tech Stack

- **IaC:** Any tool of your choice (**Terraform preferred**, but others are allowed if justified).
- **AWS Services:** VPC, API Gateway, Lambda, CloudWatch, NAT Gateway, RDS or EC2.
- **CI/CD:** GitHub Actions for automation 🏗
- **Code Quality:** Pre-commit hooks for linting and security checks 🛡

### 📄 Expected Deliverables

A Pull Request with:

- ✅ **An IaC module** that deploys the entire architecture.
- ✅ **A `README.md`** with deployment instructions and tool selection justification.
- ✅ **A working API Gateway endpoint** that responds with a JSON payload from the Lambda, including:
  - Connection status to the database or backend.
  - Basic metadata about the target system (e.g., DB version, instance type, WordPress version, etc.).
- ✅ **CloudWatch logs** from the Lambda.

## 🌟 Nice to Have

✨ **GitHub Actions to validate IaC** (e.g., `terraform fmt`, `terraform validate`, or equivalent for chosen tool).
✨ **Pre-commit hooks** to ensure linting and formatting checks before commits.
✨ **Tests for your IaC code** using `terraform validate`, `Terratest`, or equivalent for chosen tool.
✨ **Monitoring alerts** (e.g., AWS CloudWatch Alarms for Lambda errors).
✨ **Docker or Docker Compose** to facilitate local testing, such as:

- Running a local database to simulate connectivity 🛠
- Providing a local environment to test API interactions before deployment 🖥

## 📥 Submission Guidelines

1️⃣ **Fork this repository.**
2️⃣ **Create a feature branch** for your implementation.
3️⃣ **Commit your changes** with meaningful commit messages.
4️⃣ **Open a Pull Request** following the provided template.
5️⃣ **Our team will review** and provide feedback.

## ✅ Evaluation Criteria

🔍 **Correctness and completeness** of the solution.
🔍 **Code quality, modularity, and best practices.**
🔍 **Security considerations** in networking and IAM roles.
🔍 **Automation using CI/CD and pre-commit hooks.**
🔍 **Justification for chosen IaC tool(s).**
🔍 **Documentation clarity.**

🎯 **Good luck and happy coding!** 🚀
