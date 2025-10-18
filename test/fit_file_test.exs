defmodule FitFileTest do
  use ExUnit.Case
  doctest FitFile
  doctest FitFile.DataRecord

  alias FitFile.{DataField, DataRecord}

  @sample_file_path "priv/sample.fit"

  describe "DataRecord.get_field_value/2" do
    test "returns field value when field exists" do
      record = %DataRecord{
        kind: "record",
        fields: [
          %DataField{name: "speed", value: "10.5", units: "m/s"},
          %DataField{name: "distance", value: "100", units: "m"}
        ]
      }

      assert DataRecord.get_field_value(record, "speed") == "10.5"
      assert DataRecord.get_field_value(record, "distance") == "100"
    end

    test "returns nil when field does not exist" do
      record = %DataRecord{
        kind: "record",
        fields: [%DataField{name: "speed", value: "10.5", units: "m/s"}]
      }

      assert DataRecord.get_field_value(record, "nonexistent") == nil
    end
  end

  describe "DataRecord.get_field/2" do
    test "returns complete field when it exists" do
      field = %DataField{name: "speed", value: "10.5", units: "m/s"}
      record = %DataRecord{kind: "record", fields: [field]}

      assert DataRecord.get_field(record, "speed") == field
    end

    test "returns nil when field does not exist" do
      record = %DataRecord{
        kind: "record",
        fields: [%DataField{name: "speed", value: "10.5", units: "m/s"}]
      }

      assert DataRecord.get_field(record, "nonexistent") == nil
    end
  end

  describe "FitFile.from_file/1 with sample FIT file" do
    test "successfully parses sample.fit file" do
      assert {:ok, records} = FitFile.from_file(@sample_file_path)

      # Should have parsed some records
      assert is_list(records)
      assert length(records) > 0

      # All records should be DataRecord structs
      assert Enum.all?(records, fn r -> match?(%DataRecord{}, r) end)

      # Each record should have a kind and fields
      Enum.each(records, fn record ->
        assert is_binary(record.kind)
        assert is_list(record.fields)
        assert Enum.all?(record.fields, fn f -> match?(%DataField{}, f) end)
      end)
    end

    test "parses file_id record from sample.fit" do
      assert {:ok, records} = FitFile.from_file(@sample_file_path)

      # Find file_id record
      file_id = Enum.find(records, fn r -> r.kind == "file_id" end)

      if file_id do
        assert %DataRecord{kind: "file_id"} = file_id
        assert length(file_id.fields) > 0

        # File ID typically contains fields like type, manufacturer, product, etc.
        field_names = Enum.map(file_id.fields, & &1.name)
        assert is_list(field_names)
      end
    end

    test "can extract record messages from sample.fit" do
      assert {:ok, records} = FitFile.from_file(@sample_file_path)

      # Filter for "record" type messages (actual data points)
      record_messages = Enum.filter(records, fn r -> r.kind == "record" end)

      # Print summary info
      IO.puts("\nSample FIT file contains #{length(records)} total records")
      IO.puts("Record types: #{records |> Enum.map(& &1.kind) |> Enum.uniq() |> Enum.join(", ")}")
      IO.puts("Number of data point records: #{length(record_messages)}")

      if length(record_messages) > 0 do
        first_record = List.first(record_messages)

        IO.puts(
          "\nFirst record fields: #{Enum.map(first_record.fields, & &1.name) |> Enum.join(", ")}"
        )
      end
    end
  end

  describe "FitFile.from_binary/1 with sample FIT file" do
    test "successfully parses sample.fit from binary" do
      binary_data = File.read!(@sample_file_path)
      assert {:ok, records} = FitFile.from_binary(binary_data)

      assert is_list(records)
      assert length(records) > 0
    end
  end

  describe "FitFile.parse/1 with sample FIT file" do
    test "auto-detects file path and parses successfully" do
      assert {:ok, records} = FitFile.parse(@sample_file_path)
      assert length(records) > 0
    end

    test "auto-detects binary data and parses successfully" do
      binary_data = File.read!(@sample_file_path)
      assert {:ok, records} = FitFile.parse(binary_data)
      assert length(records) > 0
    end
  end
end
