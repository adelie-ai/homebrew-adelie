# frozen_string_literal: true

# Build MCP servers from CLI commands. Repo and installed binary are both `command-mcp`.
class CommandMcp < Formula
  desc "Build MCP servers from CLI commands (command-mcp) for the Adelie assistant"
  homepage "https://github.com/adelie-ai/command-mcp"
  url "https://github.com/adelie-ai/command-mcp.git",
      revision: "cda7b8c59c0750539037a091efd564f31053024a"
  version "0.1.0"
  head "https://github.com/adelie-ai/command-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: command-mcp serve
    EOS
  end

  test do
    assert_match "command-mcp", shell_output("#{bin}/command-mcp --help 2>&1")
  end
end
