# frozen_string_literal: true

# Internet-radio playback MCP server. Pure Rust, but spawns `mpv` to play streams.
class InternetRadioMcp < Formula
  desc "MCP server for internet-radio playback (Adelie assistant)"
  homepage "https://github.com/adelie-ai/internet-radio-mcp"
  url "https://github.com/adelie-ai/internet-radio-mcp.git",
      revision: "aa4f99b2d9c14f7be7a70d4cdb44532be949d0a5"
  version "0.1.0"
  head "https://github.com/adelie-ai/internet-radio-mcp.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider)
  depends_on "rust" => :build

  depends_on "mpv"                   # runtime: stream playback

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Run as an MCP server with: internet-radio-mcp serve
      Requires `mpv` on PATH for playback (installed as a dependency).
    EOS
  end

  test do
    assert_match "internet-radio-mcp", shell_output("#{bin}/internet-radio-mcp --help 2>&1")
  end
end
