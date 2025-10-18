# Release Guide

This document describes how to create a new release of the FitFile library.

## Prerequisites

- Write access to the GitHub repository
- Hex.pm account with publish permissions
- All tests passing on main branch

## Release Checklist

### 1. Prepare the Release

- [ ] Ensure all changes are merged to `main`
- [ ] Run tests locally: `mix test`
- [ ] Update version number in `mix.exs`
- [ ] Update `CHANGELOG.md` with new version and changes
- [ ] Update README if needed for new features
- [ ] Commit changes: `git commit -am "Release v0.x.0"`

### 2. Create Git Tag

```bash
# Create an annotated tag
git tag -a v0.x.0 -m "Release v0.x.0"

# Push the tag to GitHub
git push origin v0.x.0
```

### 3. Automated Build Process

Once you push the tag, GitHub Actions will automatically:

1. **Build NIFs** for all platforms:
   - All platforms built using `philss/rustler-precompiled-action`
   - Cross-compilation handled automatically (Linux ARM64 uses `cross` internally)
   - Parallel builds for faster completion

2. **Create Release**:
   - Generate release notes from commits
   - Upload precompiled binaries
   - Generate SHA256 checksums

3. **Monitor Progress**:
   - Visit: `https://github.com/col/fit_file/actions`
   - Watch the "Precompile NIFs" workflow
   - Builds typically complete in 5-10 minutes (parallel execution)

### 4. Verify Release

- [ ] Check that all platform binaries were uploaded to the GitHub release
- [ ] Verify checksums are present
- [ ] Download and test a binary on your platform (optional)

### 5. Publish to Hex

After the GitHub release is created successfully:

```bash
# Ensure you're on the tagged version
git checkout v0.x.0

# Publish to Hex
mix hex.publish
```

Follow the prompts to:
- Review package contents
- Confirm the publication

### 6. Post-Release

- [ ] Verify package appears on https://hex.pm/packages/fit_file
- [ ] Test installation in a fresh project
- [ ] Announce the release (if applicable)
- [ ] Return to main branch: `git checkout main`

## Troubleshooting

### Build Failures

If the GitHub Actions build fails:

1. Check the workflow logs for specific errors
2. Common issues:
   - **rustler-precompiled-action failures**: The action handles all compilation
     - Check if the Rust target is properly configured in the matrix
     - Verify project version extraction from mix.exs is working
   - **Cross-compilation issues**: The action uses `cross` internally for ARM64
     - Usually resolved automatically by the action
   - **Rust toolchain**: Action installs the correct toolchain automatically

3. Fix the issue and create a new patch version

**Note**: The workflow uses `philss/rustler-precompiled-action` which greatly simplifies the build process. Most compilation issues are handled automatically by this action.

### Failed Hex Publication

If `mix hex.publish` fails:

1. Ensure you're authenticated: `mix hex.user whoami`
2. Check package validation: `mix hex.build`
3. Common issues:
   - Missing required metadata in `mix.exs`
   - Package files not included
   - Version conflicts

## Testing Precompiled Binaries

To test that precompiled binaries work correctly:

```bash
# Create a test project
mix new fit_file_test
cd fit_file_test

# Add dependency (use the new version)
# Edit mix.exs to add: {:fit_file, "~> 0.x.0"}

# Install and compile (should use precompiled binary)
mix deps.get
mix compile

# The library should download the precompiled binary
# and NOT compile Rust code
```

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features, backward compatible
- **PATCH** (0.0.X): Bug fixes, backward compatible

## Questions?

For issues with the release process, open an issue on GitHub or contact the maintainers.
