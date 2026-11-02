defmodule Mix.Tasks.Compile.BinaryPhoenixCms do
  use Mix.Task.Compiler
  @moduledoc false
  @root __DIR__
  @checksums %{
    "ebin/Elixir.PhoenixCMS.ContentType.beam" =>
      "3DC390A7FC54E35C618D90734033578E5D2C9A92510EEE5B2070DFA60B625AAD",
    "ebin/Elixir.PhoenixCMS.EmailImage.beam" =>
      "95200EEB3953003B4E7D5C1241596D84E78D8CFC3F057CE4322566BACE8F3432",
    "ebin/Elixir.PhoenixCMS.Revisions.beam" =>
      "BDF1C55782727BE98E4EEF8C367BBA29CA88B27C5157BA21C09D43574076FCA3",
    "ebin/Elixir.PhoenixCMS.VersionStore.beam" =>
      "F0B4721C4BE130900CA4D354AE84E6C934E2D9736B848C544900E5750438383D",
    "ebin/phoenix_cms.app" => "91ABA4B1C23FBA17444CED834836AD740E2A87D2421618BF8EDFA4D13D0610A9"
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
      version: "0.0.4",
      elixir: "~> 1.20.0",
      compilers: [:binary_phoenix_cms],
      deps: [ecto_sql: "~> 3.13"]
    ]
  end

  def application, do: [extra_applications: [:logger, :crypto]]
end
