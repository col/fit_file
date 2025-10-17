defmodule FitFile.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  # For development, always build from source. For production releases, you can
  # configure rustler_precompiled to download from GitHub releases
  use RustlerPrecompiled,
    otp_app: :fit_file,
    crate: "fit_file_native",
    base_url: "https://github.com/yourusername/fit_file/releases/download/v#{version}",
    force_build:
      System.get_env("RUSTLER_PRECOMPILATION_FIT_FILE_BUILD") in ["1", "true"] or
        Mix.env() == :dev or Mix.env() == :test,
    version: version,
    targets: ~w(
      aarch64-apple-darwin
      x86_64-apple-darwin
      x86_64-unknown-linux-gnu
      aarch64-unknown-linux-gnu
      x86_64-pc-windows-msvc
      x86_64-pc-windows-gnu
    )

  # When the NIF is loaded, these functions will be overridden
  def parse_from_bytes(_data), do: :erlang.nif_error(:nif_not_loaded)
  def parse_from_file(_path), do: :erlang.nif_error(:nif_not_loaded)
end
