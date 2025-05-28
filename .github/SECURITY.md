# Security Policy for AWS Deployment Demo

## Security Scanning and Known Issues

This repository is a demonstration project showcasing AWS deployment with Terraform. As such, it intentionally contains certain security configurations that would not be appropriate for production environments but are acceptable for educational purposes.

### Terraform Security Considerations

Our Terraform code has been scanned with `tfsec` and flagged the following security considerations that are **acceptable for this demo**:

1. **Security Groups with `0.0.0.0/0` Ingress/Egress**
   - **Risk**: Opens services to all internet IPs
   - **Why in demo**: Allows easy public access for showcasing the application
   - **Production recommendation**: Restrict to specific IP ranges

2. **Public-facing Load Balancer (`internal = false`)**
   - **Risk**: Exposes services to the internet
   - **Why in demo**: Required for public access to the demo
   - **Production recommendation**: Use WAF, implement strict security groups

3. **Public Subnets**
   - **Risk**: Resources receive public IPs
   - **Why in demo**: Simplifies architecture for demonstration
   - **Production recommendation**: Use private subnets for application resources

4. **ECR Image Tag Mutability**
   - **Risk**: Tags can be overwritten
   - **Why in demo**: Allows easy updates during demo development
   - **Production recommendation**: Set ECR tag mutability to IMMUTABLE

5. **Load Balancer Configuration**
   - **Risk**: Default settings for invalid headers
   - **Why in demo**: Uses default AWS configurations
   - **Production recommendation**: Set `drop_invalid_header_fields = true`

6. **Missing VPC Flow Logs**
   - **Risk**: No network traffic auditing
   - **Why in demo**: Reduces complexity and cost for demo purposes
   - **Production recommendation**: Enable VPC flow logs for security monitoring

7. **Missing Encryption Configuration**
   - **Risk**: Data may be stored unencrypted
   - **Why in demo**: Uses default AWS configurations
   - **Production recommendation**: Enable encryption for all sensitive data

### npm Package Vulnerabilities

Our application dependencies have been audited with `npm audit`:

1. **AWS Demo App**: No vulnerabilities
   - All Clerk-related dependencies have been removed

2. **Slidev Presentation Tool**: Contains moderate vulnerabilities
   - Vulnerabilities exist in dependencies like `dompurify` and `esbuild`
   - These are isolated to the presentation component and don't affect the main application
   - These are accepted for demo purposes

## Reporting a New Security Issue

If you discover additional security vulnerabilities in this project:

1. **Do not** disclose them publicly until they have been addressed.
2. Create a confidential issue in this repository.
3. Provide details about the vulnerability including steps to reproduce.

## Security Acknowledgement

By using this project, you acknowledge that:

1. This is **NOT** production-ready code from a security perspective
2. The security configurations are intentionally simplified for demonstration
3. Production deployments would require significant security hardening

## Security Update Schedule

As this is a demonstration project, security updates are made on a best-effort basis. We've already taken the following actions:

- Removed vulnerable Clerk dependencies
- Documented all known security considerations in Terraform
- Added appropriate disclaimers in the README

For more details on security considerations and the approach taken for this demo, please see the main [SECURITY.md](../SECURITY.md) file.
