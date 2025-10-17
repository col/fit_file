defmodule FitFile.DataField do
  @moduledoc """
  Represents a single data field from a FIT file.

  Each field contains a name, value, and optional units.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          units: String.t() | nil
        }

  defstruct [:name, :value, :units]
end
