#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  CodeLedger — Install Script
#
#  This script installs CodeLedger from a local zip distribution.
#  Run it from inside the extracted directory.
#
#  Usage:
#    ./install.sh                     # Install globally
#    ./install.sh --local             # Install as a dev dependency in cwd
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }
step()  { echo -e "\n${BOLD}$*${NC}"; }

# ── Preflight checks ────────────────────────────────────────────────────────

step "1. Checking prerequisites..."

# Node.js
if ! command -v node >/dev/null 2>&1; then
  error "Node.js is not installed."
  echo "  CodeLedger requires Node.js >= 20."
  echo "  Install it from: https://nodejs.org"
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
  error "Node.js version $(node -v) is too old. CodeLedger requires >= 20."
  echo "  Update from: https://nodejs.org"
  exit 1
fi
info "Node.js $(node -v)"

# npm
if ! command -v npm >/dev/null 2>&1; then
  error "npm is not installed."
  exit 1
fi
info "npm $(npm -v)"

# Git
if ! command -v git >/dev/null 2>&1; then
  error "Git is not installed."
  echo "  CodeLedger uses git for churn analysis and worktrees."
  echo "  Install it from: https://git-scm.com"
  exit 1
fi
info "Git $(git --version | awk '{print $3}')"

# ── Install ──────────────────────────────────────────────────────────────────

step "2. Installing CodeLedger..."

MODE="${1:-global}"

if [ "$MODE" = "--local" ]; then
  npm install @codeledger/cli
  info "Installed @codeledger/cli as a local dependency"
  echo "  Run with: npx codeledger <command>"
else
  npm install -g @codeledger/cli
  info "Installed @codeledger/cli globally"
  echo "  Run with: codeledger <command>"
fi

# ── Verify installation ─────────────────────────────────────────────────────

step "3. Verifying installation..."

if command -v codeledger >/dev/null 2>&1; then
  VERSION=$(codeledger --version 2>/dev/null || echo "unknown")
  info "CodeLedger $VERSION is ready"
elif npx codeledger --version >/dev/null 2>&1; then
  VERSION=$(npx codeledger --version 2>/dev/null || echo "unknown")
  info "CodeLedger $VERSION is ready (via npx)"
else
  error "Installation verification failed."
  echo "  Try running: npm install -g @codeledger/cli"
  exit 1
fi

# ── Next steps ───────────────────────────────────────────────────────────────

step "4. Next steps"
echo ""
echo "  Initialize CodeLedger in your project:"
echo ""
echo "    cd your-project"
echo "    codeledger init"
echo "    codeledger activate --task \"your task description\""
echo ""
echo "  That's it. Your agent now has context at .codeledger/active-bundle.md"
echo ""
echo "  For the full getting-started guide, see GETTING-STARTED.md"
echo ""
