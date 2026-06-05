# frozen_string_literal: true

# General-purpose MCP server. Repo is `gen-mcp`; the installed binary is `genmcp`.
# Pure Rust (rustls).
class GenMcp < Formula
  desc "General-purpose MCP server (genmcp) for the Adelie assistant"
  homepage "https://github.com/adelie-ai/gen-mcp"
  url "https://github.com/adelie-ai/gen-mcp.git",
      revision: "e3b71463bc74f6430c5d5b07b90521f9ba7fa7ad"
  version "0.1.0"
  head "https://github.com/adelie-ai/gen-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: genmcp serve
    EOS
  end

  test do
    assert_match "genmcp", shell_output("#{bin}/genmcp --help 2>&1")
  end
end
