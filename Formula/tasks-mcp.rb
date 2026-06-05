# frozen_string_literal: true

# Task-management MCP server. Pure Rust; uses zbus, so its `dbus` activation mode
# needs a D-Bus session bus (Linux). The `serve` (stdio) mode works anywhere.
class TasksMcp < Formula
  desc "MCP server for task management (Adelie assistant)"
  homepage "https://github.com/adelie-ai/tasks-mcp"
  url "https://github.com/adelie-ai/tasks-mcp.git",
      revision: "7d5f46e1211028b033f068f52a01dd346741209b"
  version "0.1.0"
  head "https://github.com/adelie-ai/tasks-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: tasks-mcp serve
      The `tasks-mcp dbus` activation mode requires a D-Bus session bus (Linux).
    EOS
  end

  test do
    assert_match "tasks-mcp", shell_output("#{bin}/tasks-mcp --help 2>&1")
  end
end
