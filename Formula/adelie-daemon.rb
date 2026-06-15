# frozen_string_literal: true

# The Adelie desktop-assistant daemon (orchestrator) plus its D-Bus bridge helper.
#
# Linux-only: it stores secrets via the freedesktop Secret Service, registers a
# D-Bus name, and ships systemd user units. It needs PostgreSQL + pgvector at
# runtime for conversation storage and embeddings (the FTS/vector hybrid search).
class AdelieDaemon < Formula
  desc "Adelie desktop assistant daemon (orchestrator + D-Bus bridge helper)"
  homepage "https://github.com/adelie-ai/desktop-assistant"
  url "https://github.com/adelie-ai/desktop-assistant.git",
      revision: "d7f566d87aa8546494f3930d37704724c0e8dfac"
  version "0.1.0"
  license "AGPL-3.0-or-later"
  head "https://github.com/adelie-ai/desktop-assistant.git", branch: "main"

  # Linux only: Secret Service keyring + D-Bus + systemd are not available on macOS.
  depends_on :linux

  depends_on "cmake" => :build       # aws-lc-rs (rustls crypto provider) builds via cmake
  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  # Runtime data store: PostgreSQL with the pgvector extension.
  depends_on "pgvector"
  depends_on "postgresql@17"

  def install
    # Two binaries live in two workspace crates; build them in one pass.
    system "cargo", "build", "--release", "--locked",
           "--bin", "desktop-assistant-daemon",
           "--bin", "adelie-dbus-bridge"
    bin.install "target/release/desktop-assistant-daemon",
                "target/release/adelie-dbus-bridge"

    # Reference material: systemd user units, D-Bus activation files, env sample.
    pkgshare.install "systemd" if Dir.exist?("systemd")
    pkgshare.install ".env.example" if File.exist?(".env.example")
    (pkgshare/"assets").install Dir["assets/*.png"] if Dir.exist?("assets")
  end

  def caveats
    <<~EOS
      The daemon requires PostgreSQL with the pgvector extension. First-time setup:
        brew services start postgresql@17
        createdb desktop_assistant
        psql desktop_assistant -c 'CREATE EXTENSION IF NOT EXISTS vector;'

      Configure DATABASE_URL and your LLM provider keys (sample:
      #{opt_pkgshare}/.env.example).

      systemd user units are installed under #{opt_pkgshare}/systemd. To run the
      daemon as a user service, point ExecStart at this keg and enable it:
        mkdir -p ~/.config/systemd/user
        sed 's#%h/.cargo/bin/desktop-assistant-daemon#'#{opt_bin}'/desktop-assistant-daemon#' \\
          #{opt_pkgshare}/systemd/desktop-assistant-daemon.service \\
          > ~/.config/systemd/user/desktop-assistant-daemon.service
        systemctl --user daemon-reload
        systemctl --user enable --now desktop-assistant-daemon

      Helper binary: adelie-dbus-bridge (D-Bus bridge). Local clients authenticate
      to the daemon over UDS by kernel peer-cred — no JWT minter is needed.
    EOS
  end

  test do
    assert_path_exists bin/"desktop-assistant-daemon"
    assert_path_exists bin/"adelie-dbus-bridge"
  end
end
