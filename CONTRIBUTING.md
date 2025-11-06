# Contributing to Azure Linux Web App - ALZ Compliant Module

Thank you for your interest in contributing to this project! We welcome contributions from the community.

## How to Contribute

### Reporting Issues
- Search existing issues before creating a new one
- Provide detailed information including Terraform version, Azure provider version, and error messages
- Include steps to reproduce the issue

### Suggesting Enhancements
- Open an issue describing the enhancement
- Explain the use case and benefits
- Be open to discussion and feedback

### Submitting Pull Requests

1. **Fork the repository** and create a new branch from `main`
2. **Make your changes** following the coding standards below
3. **Test your changes** thoroughly
4. **Update documentation** if needed (README.md, examples, etc.)
5. **Submit a pull request** with a clear description of the changes

## Coding Standards

### Terraform Code Style
- Follow [Terraform style conventions](https://www.terraform.io/docs/language/syntax/style.html)
- Use `terraform fmt` to format code
- Use meaningful variable and resource names
- Add comments for complex logic

### Documentation
- Keep README.md up to date
- Update examples when adding new features
- Include inline comments in code where helpful

### Testing
Before submitting:
- Run `terraform fmt -recursive` to format all files
- Run `terraform validate` on all modules and examples
- Test examples in a real Azure environment when possible

## Module Structure

```
.
├── modules/
│   └── linux-webapp/     # Main module
├── examples/             # Usage examples
│   ├── basic/
│   ├── diagnostics/
│   └── private-ase/
├── README.md            # Main documentation
└── .gitignore
```

## Questions?

If you have questions about contributing, please open an issue for discussion.

Thank you for contributing! 🎉
