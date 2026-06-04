#!/usr/bin/env bash
# Install local git hooks. Run once after cloning.
#
#   ./scripts/install-hooks.sh
#
# The hooks run `nix fmt -- --check` and `nix flake check --no-build` before
# every commit. They no-op if `nix` isn't on PATH (CI does the same checks).

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
hook="$repo_root/.git/hooks/pre-commit"

cat > "$hook" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v nix >/dev/null 2>&1; then
  echo "pre-commit: nix not on PATH, skipping checks" >&2
  exit 0
fi

# Only check staged .nix files. If none are staged, skip.
staged_nix=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.nix$' || true)
if [ -z "$staged_nix" ]; then
  exit 0
fi

echo "pre-commit: nix fmt check..."
nix fmt -- --check . >/dev/null

echo "pre-commit: nix flake check (eval-only)..."
nix flake check --no-build >/dev/null

echo "pre-commit: ok"
EOF

chmod +x "$hook"
echo "Installed pre-commit hook at $hook"
