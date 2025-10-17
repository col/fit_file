defmodule FitFileTest do
  use ExUnit.Case
  doctest FitFile
  doctest FitFile.DataRecord

  alias FitFile.{DataField, DataRecord}

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
end
