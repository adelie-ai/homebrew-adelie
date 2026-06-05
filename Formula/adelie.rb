# frozen_string_literal: true

# Convenience meta-formula: the core Adelie assistant (daemon + terminal client).
# Install individual pieces instead if you don't want both.
class Adelie < Formula
  desc "Adelie desktop assistant — core (daemon + terminal client)"
  homepage "https://github.com/adelie-ai/desktop-assistant"
  url "https://github.com/adelie-ai/desktop-assistant.git",
      revision: "8421933c0dcb76d66e9f63b7942d9a1d11b683d7"
  version "0.1.0"
  license "AGPL-3.0-or-later"

  depends_on "adelie-ai/adelie/adele-tui"
  depends_on "adelie-ai/adelie/adelie-daemon"

  def install
    (pkgshare/"README").write <<~EOS
      Meta-formula. Installs adelie-daemon + adele-tui.
      GUI client:   brew install adelie-ai/adelie/adele-gtk
      Voice:        brew install adelie-ai/adelie/adele-voice
      MCP servers:  brew install adelie-ai/adelie/adelie-mcp
    EOS
  end

  test do
    assert_path_exists prefix/"share/adelie/README"
  end
end
