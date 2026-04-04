# TEST-NEEDS.md — CRG Grade B Test Suite

This file documents the six independently runnable test targets that bring
`blue-screen-of-app` to **CRG Grade B**.

## Grade B Status: ACHIEVED

| Target | Recipe | Command | Description |
|--------|--------|---------|-------------|
| T1 | `just test-deno` | `deno task test` | 38 Deno-native unit + integration tests across 4 files |
| T2 | `just test-zig` | `zig test ffi/zig/test/integration_test.zig` | Zig FFI integration test |
| T3 | `just test-lint` | `deno lint src/server.js` | Deno linter check on server source |
| T4 | `just test-fmt` | `deno fmt --check src/server.js` | Deno formatter check on server source |
| T5 | `just test-config` | `nickel typecheck config.ncl` | Nickel type-check for config.ncl |
| T6 | `just test-structure` | `bash tests/validate_structure.sh` | Validates required RSR files and structure |

## Running All Targets

```
just test
```

This runs all 6 targets in order: `test-structure test-lint test-fmt test-config test-deno test-zig`.

## Notes

- T2 (`test-zig`) requires `zig` to be installed. If not present, it will fail with a clear error.
- T5 (`test-config`) requires `nickel` to be installed (available at `~/.local/bin/nickel`).
- All targets produce clear PASS/FAIL output.
