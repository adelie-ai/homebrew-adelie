# frozen_string_literal: true

# Terminal (TUI) client for the Adelie assistant. Pure Rust, no native GUI deps,
# so it builds on both Linux and macOS. The installed binary is named `adele`.
class AdeleTui < Formula
  desc "Terminal client for the Adelie desktop assistant"
  homepage "https://github.com/adelie-ai/adele-tui"
  url "https://github.com/adelie-ai/adele-tui.git",
      revision: "9579ec0a9943ad230f938b39566038890a16d834"
  version "0.1.0"
  license "AGPL-3.0-or-later"
  head "https://github.com/adelie-ai/adele-tui.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider) builds via cmake
  depends_on "rust" => :build

  def install
    # Cargo.toml already pulls the shared desktop-assistant crates over git,
    # so this builds standalone with the committed lockfile.
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Launch with: adele
      The client talks to a running adelie-daemon over its WebSocket/UDS (or, on
      Linux, D-Bus) transport. Install and start `adelie-daemon` separately.
    EOS
  end

  test do
    assert_match "adele", shell_output("#{bin}/adele --help 2>&1")
  end
end
