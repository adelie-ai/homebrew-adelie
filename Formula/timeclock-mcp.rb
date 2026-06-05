# frozen_string_literal: true

# Time-tracking MCP server. Pure Rust.
class TimeclockMcp < Formula
  desc "MCP server for time tracking (Adelie assistant)"
  homepage "https://github.com/adelie-ai/timeclock-mcp"
  url "https://github.com/adelie-ai/timeclock-mcp.git",
      revision: "a8011c2919b1af5e102ee3d142bb079172f16ac1"
  version "0.1.0"
  head "https://github.com/adelie-ai/timeclock-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: timeclock-mcp serve
    EOS
  end

  test do
    assert_match "timeclock-mcp", shell_output("#{bin}/timeclock-mcp --help 2>&1")
  end
end
