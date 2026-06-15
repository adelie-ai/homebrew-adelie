# frozen_string_literal: true

# Convenience meta-formula: every published Adelie MCP server in one shot.
# (pim-mcp / skills-mcp / web-mcp are omitted — no public remote yet.)
class AdelieMcp < Formula
  desc "All published Adelie MCP servers"
  homepage "https://github.com/adelie-ai"
  url "https://github.com/adelie-ai/cve-mcp.git",
      revision: "0bbcc3fec75cd69cc565850b8b4d67ad5bf60011"
  version "0.1.0"

  depends_on "adelie-ai/adelie/command-mcp"
  depends_on "adelie-ai/adelie/cve-mcp"
  depends_on "adelie-ai/adelie/fileio-mcp"
  depends_on "adelie-ai/adelie/geocode-mcp"
  depends_on "adelie-ai/adelie/internet-radio-mcp"
  depends_on "adelie-ai/adelie/tasks-mcp"
  depends_on "adelie-ai/adelie/terminal-mcp"
  depends_on "adelie-ai/adelie/timeclock-mcp"
  depends_on "adelie-ai/adelie/weather-forecast-mcp"

  def install
    (pkgshare/"README").write "Meta-formula. Installs all published Adelie MCP servers."
  end

  test do
    assert_path_exists prefix/"share/adelie-mcp/README"
  end
end
