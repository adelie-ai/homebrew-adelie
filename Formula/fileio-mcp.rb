# frozen_string_literal: true

# Sandboxed file-I/O MCP server. Pure Rust.
class FileioMcp < Formula
  desc "MCP server for sandboxed file I/O (Adelie assistant)"
  homepage "https://github.com/adelie-ai/fileio-mcp"
  url "https://github.com/adelie-ai/fileio-mcp.git",
      revision: "86bb59747c5df58d173524d45176792d9e250890"
  version "0.1.0"
  head "https://github.com/adelie-ai/fileio-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: fileio-mcp serve
    EOS
  end

  test do
    assert_match "fileio-mcp", shell_output("#{bin}/fileio-mcp --help 2>&1")
  end
end
