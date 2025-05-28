# Security Policy for AWS Deployment Demo

## Security Scanning and Known Issues

This repository is a demonstration project showcasing AWS deployment with Terraform. As such, it intentionally contains certain security configurations that would not be appropriate for production environments but are acceptable for educational purposes.

### Terraform Security Considerations

For demo purposes, the Terraform configurations in this project use simplified security settings. In a production environment, you would need to implement more robust security practices:

- Restrict security group access to specific IP ranges
- Place backend services in private subnets
- Enable encryption for sensitive data
- Set immutable tags for container images
- Enable monitoring and auditing features
- Add detailed descriptions to all security group rules

For details on these considerations, see the Terraform security disclaimer in the README.md file.

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
- Documented known security considerations in the README
- Added appropriate security disclaimers

For more details on security considerations and the approach taken for this demo, please see the main [SECURITY.md](../SECURITY.md) file.
