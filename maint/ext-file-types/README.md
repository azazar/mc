# ext-file-types

Utilities for building and validating test data for `mc.ext.ini` `Type` rules.

## What is here

- `generate-file-samples.mk` — generates/updates sample files used by tests.
- `list-type-sections.pl` — lists sections in `mc.ext.ini` that define `Type=` (used by `generate-file-samples.mk`).
- `test-type-sections.pl` — checks that generated samples match their `Type` regexes (for quick checks, not actual tests).
- `collect-file-output.pl` — records `file` command output for sample files into TSV (used by `collect-file-output-samples.sh`).
- `collect-file-output-samples.sh` — runs collection in multiple distro containers.

## Typical workflow

1. Generate sample files:
	- `make -f maint/ext-file-types/generate-file-samples.mk`
2. Validate `Type` patterns against local `file` output:
	- `perl maint/ext-file-types/test-type-sections.pl`
3. (Optional) Refresh cross-distro `file` output fixtures:
	- `bash maint/ext-file-types/collect-file-output-samples.sh`
4. (Optional) Refresh OS `file` output fixtures for running OS:
    - `bash maint/ext-file-types/collect-file-output.pl output_name`

## Notes

- The collection script uses Docker images and writes TSV files under:
  `tests/src/fixtures/filemanager/file-types/file_output/`.
- This tooling is currently work-in-progress and focused on Linux container
  environments.
