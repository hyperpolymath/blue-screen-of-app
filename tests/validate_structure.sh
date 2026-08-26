#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Structural validation for blue-screen-of-app (CRG Grade B)
# Checks that all required RSR files and directories are present.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# Required documentation files
if [ -f README.adoc ]; then
  pass "README.adoc present"
else
  fail "README.adoc missing"
fi
if [ -f LICENSE ]; then
  pass "LICENSE present"
else
  fail "LICENSE missing"
fi
if [ -f SECURITY.adoc ]; then
  pass "SECURITY.adoc present"
else
  fail "SECURITY.adoc missing"
fi
if [ -f ABI-FFI-README.adoc ]; then
  pass "ABI-FFI-README.adoc present"
else
  fail "ABI-FFI-README.adoc missing"
fi

# AI manifest (0-AI-MANIFEST.a2ml OR AI.a2ml)
if [ -f 0-AI-MANIFEST.a2ml ] || [ -f AI.a2ml ]; then
  pass "AI manifest present (0-AI-MANIFEST.a2ml or AI.a2ml)"
else
  fail "AI manifest missing (neither 0-AI-MANIFEST.a2ml nor AI.a2ml found)"
fi

# Workflows — must have at least 3
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" 2>/dev/null | wc -l)
if [ "$WORKFLOW_COUNT" -ge 3 ]; then
  pass ".github/workflows has $WORKFLOW_COUNT workflow files (>= 3)"
else
  fail ".github/workflows has only $WORKFLOW_COUNT workflow files (need >= 3)"
fi

# Tests directory
if [ -d tests ]; then
  pass "tests/ directory present"
else
  fail "tests/ directory missing"
fi

# Containerfile (Podman)
if [ -f Containerfile ]; then
  pass "Containerfile present"
else
  fail "Containerfile missing"
fi

# Summary
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
