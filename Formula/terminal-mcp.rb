# frozen_string_literal: true

# Terminal / command-execution MCP server. Pure Rust.
class TerminalMcp < Formula
  desc "MCP server for terminal command execution (Adelie assistant)"
  homepage "https://github.com/adelie-ai/terminal-mcp"
  url "https://github.com/adelie-ai/terminal-mcp.git",
      revision: "994f30f76de9fcb86bb6fa61d9d172c9efe58b85"
  version "0.1.0"
  head "https://github.com/adelie-ai/terminal-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: terminal-mcp serve
    EOS
  end

  test do
    assert_match "terminal-mcp", shell_output("#{bin}/terminal-mcp --help 2>&1")
  end
end
