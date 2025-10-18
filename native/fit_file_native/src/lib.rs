use rustler::{Encoder, Env, NifResult, Term};
use std::fs::File;
use std::io::BufReader;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        // Error types
        parse_error,
        file_error,
        io_error,
    }
}

// Struct to represent a parsed FIT data field
#[derive(rustler::NifStruct)]
#[module = "FitFile.DataField"]
struct DataField {
    name: String,
    value: String,
    units: Option<String>,
}

// Struct to represent a parsed FIT data record
#[derive(rustler::NifStruct)]
#[module = "FitFile.DataRecord"]
struct DataRecord {
    kind: String,
    fields: Vec<DataField>,
}

// Helper function to convert fitparser Value to a string representation
fn value_to_string(value: &fitparser::Value) -> String {
    use fitparser::Value;

    match value {
        Value::Byte(v) => v.to_string(),
        Value::SInt8(v) => v.to_string(),
        Value::UInt8(v) => v.to_string(),
        Value::SInt16(v) => v.to_string(),
        Value::UInt16(v) => v.to_string(),
        Value::SInt32(v) => v.to_string(),
        Value::UInt32(v) => v.to_string(),
        Value::String(v) => v.clone(),
        Value::Float32(v) => v.to_string(),
        Value::Float64(v) => v.to_string(),
        Value::UInt8z(v) => v.to_string(),
        Value::UInt16z(v) => v.to_string(),
        Value::UInt32z(v) => v.to_string(),
        Value::SInt64(v) => v.to_string(),
        Value::UInt64(v) => v.to_string(),
        Value::UInt64z(v) => v.to_string(),
        Value::Timestamp(v) => format!("{:?}", v),
        Value::Enum(v) => v.to_string(),
        Value::Array(values) => {
            format!(
                "[{}]",
                values
                    .iter()
                    .map(value_to_string)
                    .collect::<Vec<_>>()
                    .join(", ")
            )
        }
        Value::Invalid => String::from("invalid"),
    }
}

// Convert fitparser FitDataRecord to our Elixir struct
fn convert_record(record: &fitparser::FitDataRecord) -> DataRecord {
    let fields: Vec<DataField> = record
        .fields()
        .iter()
        .map(|field| {
            let value_str = value_to_string(field.value());
            let units = if field.units().is_empty() {
                None
            } else {
                Some(field.units().to_string())
            };

            DataField {
                name: field.name().to_string(),
                value: value_str,
                units,
            }
        })
        .collect();

    DataRecord {
        kind: record.kind().to_string(),
        fields,
    }
}

/// Parse FIT data from a binary
#[rustler::nif]
fn parse_from_bytes<'a>(env: Env<'a>, data: Vec<u8>) -> NifResult<Term<'a>> {
    match fitparser::from_bytes(&data) {
        Ok(records) => {
            let converted_records: Vec<DataRecord> = records.iter().map(convert_record).collect();

            Ok((atoms::ok(), converted_records).encode(env))
        }
        Err(e) => {
            let error_msg = format!("{:?}", e);
            Ok((atoms::error(), (atoms::parse_error(), error_msg)).encode(env))
        }
    }
}

/// Parse FIT data from a file path
#[rustler::nif]
fn parse_from_file<'a>(env: Env<'a>, path: String) -> NifResult<Term<'a>> {
    // Open the file
    let file = match File::open(&path) {
        Ok(f) => f,
        Err(e) => {
            let error_msg = format!("Failed to open file: {}", e);
            return Ok((atoms::error(), (atoms::file_error(), error_msg)).encode(env));
        }
    };

    let mut reader = BufReader::new(file);

    // Parse the FIT file
    match fitparser::from_reader(&mut reader) {
        Ok(records) => {
            let converted_records: Vec<DataRecord> = records.iter().map(convert_record).collect();

            Ok((atoms::ok(), converted_records).encode(env))
        }
        Err(e) => {
            let error_msg = format!("{:?}", e);
            Ok((atoms::error(), (atoms::parse_error(), error_msg)).encode(env))
        }
    }
}

rustler::init!("Elixir.FitFile.Native");
