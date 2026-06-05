# frozen_string_literal: true

# Geocoding / place-lookup MCP server. Pure Rust (rustls).
class GeocodeMcp < Formula
  desc "MCP server for geocoding / place lookups (Adelie assistant)"
  homepage "https://github.com/adelie-ai/geocode-mcp"
  url "https://github.com/adelie-ai/geocode-mcp.git",
      revision: "f516642563781c247fa24c3b6526cf29838d9cbd"
  version "0.1.0"
  head "https://github.com/adelie-ai/geocode-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: geocode-mcp serve
    EOS
  end

  test do
    assert_match "geocode-mcp", shell_output("#{bin}/geocode-mcp --help 2>&1")
  end
end
