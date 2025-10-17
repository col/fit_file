defmodule FitFile.DataRecord do
  @moduledoc """
  Represents a data record from a FIT file.

  Each record has a kind (message type) and a list of fields.
  """

  alias FitFile.DataField

  @type t :: %__MODULE__{
          kind: String.t(),
          fields: [DataField.t()]
        }

  defstruct [:kind, :fields]

  @doc """
  Get a field value by name.

  Returns the field's value if found, or nil if not found.

  ## Examples

      iex> record = %FitFile.DataRecord{kind: "record", fields: [%FitFile.DataField{name: "speed", value: "10.5", units: "m/s"}]}
      iex> FitFile.DataRecord.get_field_value(record, "speed")
      "10.5"

  """
  @spec get_field_value(t(), String.t()) :: String.t() | nil
  def get_field_value(%__MODULE__{fields: fields}, field_name) do
    case Enum.find(fields, fn field -> field.name == field_name end) do
      nil -> nil
      field -> field.value
    end
  end

  @doc """
  Get a field by name.

  Returns the complete field struct if found, or nil if not found.
  """
  @spec get_field(t(), String.t()) :: DataField.t() | nil
  def get_field(%__MODULE__{fields: fields}, field_name) do
    Enum.find(fields, fn field -> field.name == field_name end)
  end
end
