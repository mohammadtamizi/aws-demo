# Contributing Guide

## Getting Started

Thank you for your interest in contributing to the AWS Demo project! This document provides guidelines and instructions for contributing to this repository.

## Development Setup

1. Fork the repository and clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/aws-demo.git
   cd aws-demo
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Install pre-commit hooks:
   ```bash
   pip install pre-commit
   pre-commit install
   ```

## Security Best Practices

### Pre-commit Hooks

This repository uses pre-commit hooks to catch potential security issues before they are committed. Please ensure you have installed the pre-commit hooks as described above.

The pre-commit hooks will:
- Check for hardcoded secrets and credentials
- Validate Terraform configurations for security issues
- Enforce code formatting standards
- Check for large files that shouldn't be committed

### Handling Sensitive Information

- **Never commit secrets directly to the repository**
- Use AWS Parameter Store, Secrets Manager, or environment variables for sensitive information
- In development, use `.env.local` files (which are ignored by git) for local environment variables

### Using Terraform

- Always use the principle of least privilege when defining IAM roles and policies
- Prefer private subnets for resources that don't need direct internet access
- Enable encryption for data at rest and in transit
- Regularly review and audit security groups and network configurations

## Pull Request Process

1. Create a new branch for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them (pre-commit hooks will run automatically)

3. Push your branch to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request against the main repository's `dev` branch

5. Ensure your PR includes:
   - A clear description of the changes
   - Any necessary documentation updates
   - Tests for new functionality
   - Security considerations addressed

6. Wait for code review and address any feedback

## Code Review Guidelines

All contributions must go through code review. During review, pay special attention to:

- Security implications of changes
- Proper error handling
- Input validation
- Performance considerations
- Adherence to project conventions

## Testing

- Add unit tests for new functionality
- Ensure existing tests pass
- For infrastructure changes, describe testing performed in non-production environments

## Reporting Security Issues

If you discover a security vulnerability, please follow the procedure outlined in our [SECURITY.md](SECURITY.md) file instead of using the public issue tracker.

## Resources

- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [GitHub Security Documentation](https://docs.github.com/en/code-security)

Thank you for helping to make this project more secure!
