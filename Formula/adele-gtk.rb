# frozen_string_literal: true

# GTK4 desktop client for the Adelie assistant.
#
# Linux-only: it uses GTK4 + WebKitGTK 6.0, the D-Bus transport, and the XDG
# settings portal. The upstream Cargo.toml depends on the sibling
# `../desktop-assistant` checkout via path deps; since Homebrew builds each repo
# in isolation, we rewrite those to pinned git deps before building.
class AdeleGtk < Formula
  desc "GTK4 desktop client for the Adelie desktop assistant"
  homepage "https://github.com/adelie-ai/adele-gtk"
  url "https://github.com/adelie-ai/adele-gtk.git",
      revision: "792b9ffbb429b8984c1250232966f40e1ebf6a9f"
  version "0.1.0"
  license "AGPL-3.0-or-later"
  head "https://github.com/adelie-ai/adele-gtk.git", branch: "main"

  # GTK4 + WebKitGTK + D-Bus desktop integration are Linux-only.
  depends_on :linux

  depends_on "cmake" => :build       # aws-lc-rs / ring crypto provider
  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  depends_on "gtk4"
  depends_on "webkitgtk"             # provides webkitgtk-6.0 used by the embedded web view

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

    # Not --locked: rewriting the deps invalidates the committed lockfile, so let
    # cargo re-resolve against the git source.
    system "cargo", "install", "--root", prefix, "--path", "."

    # Desktop entry + icon (point Exec at the installed binary).
    if File.exist?("adele-gtk.desktop")
      inreplace "adele-gtk.desktop", %r{^Exec=.*$}, "Exec=#{opt_bin}/adele-gtk"
      (share/"applications").install "adele-gtk.desktop"
    end
    if File.exist?("assets/adele.png")
      (share/"icons/hicolor/512x512/apps").install "assets/adele.png" => "adele-gtk.png"
    end
  end

  def caveats
    <<~EOS
      Launch with: adele-gtk
      Needs a running adelie-daemon (D-Bus / WebSocket transport).

      If `brew install webkitgtk` is unavailable on your distro, install the
      system WebKitGTK 6.0 dev package instead (e.g. webkitgtk-6.0 on Arch,
      libwebkitgtk-6.0-dev on Debian/Ubuntu) and re-run the build.
    EOS
  end

  test do
    assert_match "adele-gtk", shell_output("#{bin}/adele-gtk --help 2>&1")
  end
end
