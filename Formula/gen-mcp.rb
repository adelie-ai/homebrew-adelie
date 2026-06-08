# frozen_string_literal: true

# General-purpose MCP server. Repo and installed binary are both `gen-mcp`.
class GenMcp < Formula
  desc "General-purpose MCP server (gen-mcp) for the Adelie assistant"
  homepage "https://github.com/adelie-ai/gen-mcp"
  url "https://github.com/adelie-ai/gen-mcp.git",
      revision: "8d54d34ff12ec3ff87c33ea90806b9ac328c504f"
  version "0.1.0"
  head "https://github.com/adelie-ai/gen-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: gen-mcp serve
    EOS
  end

  test do
    assert_match "gen-mcp", shell_output("#{bin}/gen-mcp --help 2>&1")
  end
end
