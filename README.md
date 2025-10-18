# FitFile

An Elixir wrapper for the Rust [fitparser](https://crates.io/crates/fitparser) library (v0.10.0) to parse ANT FIT files.

FIT (Flexible and Interoperable Data Transfer) is a file format commonly used by fitness devices from Garmin and other manufacturers to store activity data such as runs, bike rides, and other workouts.

## Features

- Parse FIT files from disk or binary data
- Built with Rustler for safe, fast native code execution
- Precompiled binaries available (via rustler_precompiled) - no Rust toolchain required for most users
- Type-safe Elixir structs for parsed data
- Comprehensive error handling

## Installation

Add `fit_file` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fit_file, "~> 0.1.3"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Usage

### Parse from a file

```elixir
case FitFile.from_file("path/to/activity.fit") do
  {:ok, records} ->
    IO.puts("Successfully parsed #{length(records)} records")

  {:error, {reason, message}} ->
    IO.puts("Error: #{reason} - #{message}")
end
```

### Parse from binary data

```elixir
fit_data = File.read!("path/to/activity.fit")

case FitFile.from_binary(fit_data) do
  {:ok, records} ->
    # Process records

  {:error, {reason, message}} ->
    # Handle error
end
```

### Convenience parse function

The `parse/1` function automatically detects whether you're passing a file path or binary data:

```elixir
# Parse from file
{:ok, records} = FitFile.parse("activity.fit")

# Parse from binary
{:ok, records} = FitFile.parse(binary_data)
```

## Working with Records

Each record contains:
- `kind`: The message type (e.g., "record", "session", "lap", "file_id")
- `fields`: A list of `FitFile.DataField` structs

### Example: Extract specific data

```elixir
{:ok, records} = FitFile.from_file("activity.fit")

# Filter to get only "record" messages (the actual data points)
data_points = Enum.filter(records, fn r -> r.kind == "record" end)

# Get specific field values
Enum.each(data_points, fn record ->
  timestamp = FitFile.DataRecord.get_field_value(record, "timestamp")
  speed = FitFile.DataRecord.get_field_value(record, "speed")
  heart_rate = FitFile.DataRecord.get_field_value(record, "heart_rate")

  IO.puts("Time: #{timestamp}, Speed: #{speed}, HR: #{heart_rate}")
end)
```

### Example: Get session summary

```elixir
{:ok, records} = FitFile.from_file("activity.fit")

session = Enum.find(records, fn r -> r.kind == "session" end)

if session do
  total_distance = FitFile.DataRecord.get_field_value(session, "total_distance")
  total_time = FitFile.DataRecord.get_field_value(session, "total_elapsed_time")
  avg_speed = FitFile.DataRecord.get_field_value(session, "avg_speed")

  IO.puts("Distance: #{total_distance}m, Time: #{total_time}s, Avg Speed: #{avg_speed}m/s")
end
```

## Data Structures

### FitFile.DataRecord

```elixir
%FitFile.DataRecord{
  kind: "record",
  fields: [%FitFile.DataField{}, ...]
}
```

### FitFile.DataField

```elixir
%FitFile.DataField{
  name: "speed",
  value: "5.2",
  units: "m/s"
}
```

## Development

### Building from source

If precompiled binaries aren't available for your platform, the library will automatically compile the Rust NIF. You'll need:

- Rust toolchain (install from [rustup.rs](https://rustup.rs))
- Elixir 1.18+

To force building from source:

```bash
export RUSTLER_PRECOMPILATION_FIT_FILE_BUILD=true
mix deps.get
mix compile
```

### Running tests

```bash
mix test
```

## Releasing (Maintainers)

This project uses GitHub Actions to automatically build precompiled NIFs for multiple platforms.

### Release Process

1. Update the version in `mix.exs`
2. Update `CHANGELOG.md` with the new version and changes
3. Commit the changes: `git commit -am "Release v0.x.0"`
4. Create and push a git tag: `git tag v0.x.0 && git push origin v0.x.0`
5. GitHub Actions will automatically:
   - Build NIFs for all supported platforms (macOS, Linux, Windows)
   - Create checksums for each binary
   - Create a GitHub release with all artifacts
6. After the release is created, publish to Hex: `mix hex.publish`

### Supported Platforms

Precompiled binaries are automatically built for:
- macOS: `aarch64-apple-darwin` (Apple Silicon), `x86_64-apple-darwin` (Intel)
- Linux: `x86_64-unknown-linux-gnu`, `aarch64-unknown-linux-gnu` (ARM64)
- Windows: `x86_64-pc-windows-msvc`, `x86_64-pc-windows-gnu`

## CI/CD

The project includes two GitHub Actions workflows:

- **CI** (`.github/workflows/ci.yml`): Runs on every push/PR
  - Tests across multiple Elixir/OTP versions
  - Runs formatting checks
  - Runs Rust linting (clippy, rustfmt)

- **Release** (`.github/workflows/release.yml`): Runs on tags and native path changes
  - Builds precompiled NIFs for all platforms using `rustler-precompiled-action`
  - Handles cross-compilation automatically (including Linux ARM64)
  - Creates GitHub release with artifacts
  - Can be triggered manually via workflow_dispatch

## License

MIT

## Credits

This library wraps the excellent [fitparser](https://github.com/stadelmanma/fitparse-rs) Rust crate by Matthew Stadelman.

