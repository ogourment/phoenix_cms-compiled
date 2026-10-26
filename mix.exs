defmodule Mix.Tasks.Compile.BinaryPhoenixCms do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "ebin/Elixir.PhoenixCMS.Revisions.beam" =>
      "BDF1C55782727BE98E4EEF8C367BBA29CA88B27C5157BA21C09D43574076FCA3",
    "ebin/Elixir.PhoenixCMS.VersionStore.beam" =>
      "22AC84B4E74094DD1C579436B9B2DCADB57E2C5DC5FFFC60028F143AB22A0FD0",
    "ebin/phoenix_cms.app" => "BBCEA523ECA8562141F2E2697405BBDE1BB523ADFFB8C1CFDA78620D5B789AEA"
  }

  @impl true
  def run(_args) do
    series = Version.parse!(System.version()) |> Map.take([:major, :minor])

    unless series == %{major: 1, minor: 20} and System.otp_release() == "29" do
      Mix.raise("phoenix_cms requires a binary distribution for Elixir 1.20.x / OTP 29")
    end

    for {path, expected} <- @checksums do
      bytes = File.read!(Path.join(@root, path))

      unless Base.encode16(:crypto.hash(:sha256, bytes)) == expected do
        Mix.raise("phoenix_cms artifact checksum mismatch: #{path}")
      end

      if String.starts_with?(path, "ebin/") do
        target = Path.join(Mix.Project.compile_path(), Path.basename(path))
        File.mkdir_p!(Path.dirname(target))
        File.write!(target, bytes)
      end
    end

    {:ok, []}
  end
end

defmodule Compiled.PhoenixCms.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_cms,
      version: "0.0.2",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_cms],
      deps: [ecto_sql: "~> 3.13"]
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
