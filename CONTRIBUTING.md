# Contributing

Thanks for contributing to this project.

## Fork and clone

1. Fork the repository on GitHub.
2. Clone your fork:
   ```bash
   git clone https://github.com/<your-username>/skill-image-gen.git
   cd skill-image-gen
   ```
3. Add the upstream remote if you want to keep your fork in sync:
   ```bash
   git remote add upstream https://github.com/<upstream-owner>/skill-image-gen.git
   ```

## Development setup

Use development mode so local changes are linked directly:

```bash
./install.sh --link
```

If you are testing provider integrations, export the API keys you need before running commands.

## Testing changes

Keep testing simple:

1. Verify both scripts respond to `--help`.
   ```bash
   for script in scripts/*.sh; do
     bash "$script" --help
   done
   ```
2. If you have API keys available, run real image generation checks for the providers you changed.
3. Confirm generated files and basic CLI behavior still match the existing usage pattern.

## Pull request process

1. Fork the repo.
2. Create a branch for your change.
3. Open a pull request with a short description of what changed.

Small, focused PRs are preferred.

## Code style

- Follow the existing Bash script structure and naming patterns.
- Keep scripts readable and explicit.
- Run `shellcheck` on any Bash files you modify.

## Adding a new provider

When adding a provider:

1. Create a new script in `scripts/`.
2. Follow the same CLI conventions as the existing providers.
3. Update `SKILL.md` so the new provider is documented and discoverable.
