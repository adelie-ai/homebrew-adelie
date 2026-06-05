# frozen_string_literal: true

# Weather-forecast MCP server. Pure Rust (rustls).
class WeatherForecastMcp < Formula
  desc "MCP server for weather forecasts (Adelie assistant)"
  homepage "https://github.com/adelie-ai/weather-forecast-mcp"
  url "https://github.com/adelie-ai/weather-forecast-mcp.git",
      revision: "de23d5f35fa029fb4d23e8521050efb34d70d8d6"
  version "0.1.0"
  head "https://github.com/adelie-ai/weather-forecast-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: weather-forecast-mcp serve
    EOS
  end

  test do
    assert_match "weather-forecast-mcp", shell_output("#{bin}/weather-forecast-mcp --help 2>&1")
  end
end
