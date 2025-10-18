defmodule FitFile do
  @moduledoc """
  FitFile is an Elixir wrapper for the Rust `fitparser` library to parse ANT FIT files.

  FIT (Flexible and Interoperable Data Transfer) is a file format commonly used by
  fitness devices from Garmin and other manufacturers to store activity data.

  ## Installation

  Add `fit_file` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:fit_file, "~> 0.1.4"}
    ]
  end
  ```

  ## Usage

  Parse a FIT file from disk:

  ```elixir
  {:ok, records} = FitFile.from_file("path/to/activity.fit")
  ```

  Parse FIT data from a binary:

  ```elixir
  {:ok, records} = FitFile.from_binary(fit_data)
  ```

  The convenience function `parse/1` accepts either a file path or binary:

  ```elixir
  {:ok, records} = FitFile.parse("path/to/activity.fit")
  {:ok, records} = FitFile.parse(fit_binary)
  ```

  ## Working with Records

  Each record contains a kind (message type) and a list of fields:

  ```elixir
  {:ok, records} = FitFile.from_file("activity.fit")

  # Filter records by type
  record_messages = Enum.filter(records, fn r -> r.kind == "record" end)

  # Get a specific field value
  first_record = List.first(record_messages)
  speed = FitFile.DataRecord.get_field_value(first_record, "speed")
  ```
  """

  alias FitFile.{DataRecord, Native}

  @type parse_result :: {:ok, [DataRecord.t()]} | {:error, {atom(), String.t()}}

  @doc """
  Parse FIT data from either a file path (string) or binary data.

  This is a convenience function that automatically determines whether the input
  is a file path or binary data.

  ## Examples

      # Parse from a file
      {:ok, records} = FitFile.parse("/path/to/activity.fit")

      # Parse from binary
      {:ok, records} = FitFile.parse(binary_data)

  """
  @spec parse(String.t() | binary()) :: parse_result()
  def parse(input) when is_binary(input) do
    # Check if it looks like a file path (heuristic: doesn't contain binary data)
    if String.printable?(input) and
         (String.starts_with?(input, "/") or String.contains?(input, ".")) do
      from_file(input)
    else
      from_binary(input)
    end
  end

  @doc """
  Parse a FIT file from a file path.

  ## Examples

      {:ok, records} = FitFile.from_file("/path/to/activity.fit")

      case FitFile.from_file(path) do
        {:ok, records} ->
          IO.puts("Parsed \#{length(records)} records")
        {:error, {reason, message}} ->
          IO.puts("Error: \#{reason} - \#{message}")
      end

  """
  @spec from_file(String.t()) :: parse_result()
  def from_file(path) when is_binary(path) do
    Native.parse_from_file(path)
  end

  @doc """
  Parse FIT data from a binary.

  ## Examples

      fit_data = File.read!("/path/to/activity.fit")
      {:ok, records} = FitFile.from_binary(fit_data)

  """
  @spec from_binary(binary()) :: parse_result()
  def from_binary(data) when is_binary(data) do
    # Convert binary to list of bytes for Rust
    bytes = :binary.bin_to_list(data)
    Native.parse_from_bytes(bytes)
  end
end
