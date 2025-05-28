# Git Workflow Guidelines

This project follows a Feature Branch Workflow to maintain code quality and streamline the development process.

## Branch Structure

- **main**: Production-ready code
  - Protected branch
  - Only updated via pull requests from dev
  - Each commit on main should be deployable to production

- **dev**: Development branch
  - Primary branch for ongoing development
  - All feature work is integrated here first
  - Testing is performed on this branch before promotion to main

## Development Process

### Basic Workflow

1. **Always start with the latest code**
   ```bash
   git checkout dev
   git pull origin dev
   ```

2. **Make your changes directly on dev** (for small changes)
   ```bash
   # After making changes
   git add .
   git commit -m "Descriptive message"
   git push origin dev
   ```

3. **For larger features, create a feature branch** (optional)
   ```bash
   git checkout -b feature/new-feature dev
   # Make changes
   git add .
   git commit -m "Implement new feature"
   git push -u origin feature/new-feature
   ```

4. **Create a pull request to merge back to dev**
   - Use GitHub's interface to create a PR
   - Request code reviews from team members
   - Address any feedback
   - Merge when approved

5. **Delete feature branch after merge** (if used)
   ```bash
   git checkout dev
   git pull origin dev
   git branch -d feature/new-feature
   git push origin --delete feature/new-feature
   ```

## Releasing to Production

When the dev branch is stable and ready for production:

1. Create a pull request from dev to main
2. Conduct final review and testing
3. Merge the PR to update main
4. Tag the release with a version number
   ```bash
   git checkout main
   git pull origin main
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

## Best Practices

1. **Write clear commit messages** that explain why the change was made
2. **Commit frequently** with smaller logical changes
3. **Pull regularly** to avoid conflicts
4. **Never force push** to shared branches (main or dev)
5. **Keep the dev branch deployable** - fix broken builds promptly

## References

- [Atlassian Git Feature Branch Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow) 