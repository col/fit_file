# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-17

### Added
- Initial release
- Parse FIT files from disk using `FitFile.from_file/1`
- Parse FIT data from binary using `FitFile.from_binary/1`
- Convenience `FitFile.parse/1` function that auto-detects file path vs binary
- `FitFile.DataRecord` struct for parsed records
- `FitFile.DataField` struct for individual fields
- Helper functions `DataRecord.get_field/2` and `DataRecord.get_field_value/2`
- Rustler precompilation support for easier installation
- Comprehensive documentation and examples
- Wraps fitparser-rs v0.10.0

[0.1.0]: https://github.com/yourusername/fit_file/releases/tag/v0.1.0
