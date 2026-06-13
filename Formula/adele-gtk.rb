# frozen_string_literal: true

# GTK4 desktop client for the Adelie assistant.
#
# On Linux the default build uses GTK4 + WebKitGTK 6.0 (embedded web view), the
# D-Bus transport, and the XDG settings portal. On macOS, WebKitGTK 6.0 and the
# D-Bus transport are unavailable, so we build the crate's `--no-default-features`
# fallback: GTK4 only, with a Label-based view and the WebSocket transport.
#
# The upstream Cargo.toml depends on the sibling `../desktop-assistant` checkout
# via path deps; since Homebrew builds each repo in isolation, we rewrite those
# to pinned git deps before building.
class AdeleGtk < Formula
  desc "GTK4 desktop client for the Adelie desktop assistant"
  homepage "https://github.com/adelie-ai/adele-gtk"
  url "https://github.com/adelie-ai/adele-gtk.git",
      revision: "470277758733f4101563e5711b09850fbbab9c12"
  version "0.1.0"
  license "AGPL-3.0-or-later"
  head "https://github.com/adelie-ai/adele-gtk.git", branch: "main"

  depends_on "cmake" => :build       # aws-lc-rs / ring crypto provider
  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  depends_on "gtk4"

  on_linux do
    # webkitgtk-6.0 (embedded web view) + D-Bus transport are the default-feature
    # build. webkitgtk itself is Linux-only in homebrew-core.
    depends_on "webkitgtk"
  end

  # Pin the shared desktop-assistant crates to a known-good revision (matches the
  # adelie-daemon formula). Keep these in sync if you bump the daemon pin.
  DESKTOP_ASSISTANT_REV = "8421933c0dcb76d66e9f63b7942d9a1d11b683d7"

  def install
    # Rewrite the local path deps to pinned git deps so the build is hermetic.
    da_git = 'git = "https://github.com/adelie-ai/desktop-assistant.git"'
    inreplace "Cargo.toml" do |s|
      s.gsub!(
        'path = "../desktop-assistant/crates/client-common"',
        "#{da_git}\nrev = \"#{DESKTOP_ASSISTANT_REV}\"",
      )
      s.gsub!(
        'path = "../desktop-assistant/crates/api-model"',
        "#{da_git}\nrev = \"#{DESKTOP_ASSISTANT_REV}\"",
      )
    end

    # macOS lacks WebKitGTK 6.0 and the D-Bus transport; build the crate's
    # `--no-default-features` fallback (GTK4 only, Label view, WebSocket transport).
    args = ["--root", prefix, "--path", "."]
    args << "--no-default-features" if OS.mac?

    # Not --locked: rewriting the deps invalidates the committed lockfile, so let
    # cargo re-resolve against the git source.
    system "cargo", "install", *args

    # Desktop entry + icon are XDG (Linux) concepts; skip them on macOS.
    if OS.linux?
      if File.exist?("adele-gtk.desktop")
        inreplace "adele-gtk.desktop", %r{^Exec=.*$}, "Exec=#{opt_bin}/adele-gtk"
        (share/"applications").install "adele-gtk.desktop"
      end
      if File.exist?("assets/adele.png")
        (share/"icons/hicolor/512x512/apps").install "assets/adele.png" => "adele-gtk.png"
      end
    end
  end

  def caveats
    if OS.mac?
      <<~EOS
        Launch with: adele-gtk

        Built without WebKitGTK 6.0 / D-Bus (unavailable on macOS): the UI uses the
        Label-based fallback view and connects to the daemon over WebSocket only.
        Point it at a running adelie-daemon with --ws-url (or ADELIE_GTK_WS_URL).
      EOS
    else
      <<~EOS
        Launch with: adele-gtk
        Needs a running adelie-daemon (D-Bus / WebSocket transport).

        If `brew install webkitgtk` is unavailable on your distro, install the
        system WebKitGTK 6.0 dev package instead (e.g. webkitgtk-6.0 on Arch,
        libwebkitgtk-6.0-dev on Debian/Ubuntu) and re-run the build.
      EOS
    end
  end

  test do
    assert_match "adele-gtk", shell_output("#{bin}/adele-gtk --help 2>&1")
  end
end
