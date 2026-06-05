# frozen_string_literal: true

# Voice service for the Adelie assistant: wake word -> VAD -> STT -> assistant
# -> TTS. Default local TTS is Kokoro (ONNX) which shells out to espeak-ng for
# phonemization; STT is whisper.cpp (built via cmake). ONNX Runtime is fetched
# by the `ort` crate at build time; model weights are downloaded on first setup.
#
# Linux-only: it captures audio via ALSA (cpal), talks to the daemon over D-Bus,
# and ships a systemd user unit.
class AdeleVoice < Formula
  desc "Voice front-end (wake word, STT, TTS) for the Adelie assistant"
  homepage "https://github.com/adelie-ai/voice"
  url "https://github.com/adelie-ai/voice.git",
      revision: "98699f2784cf58f379fdb1229bb850eb19de6fe1"
  version "0.1.0"
  license "AGPL-3.0-or-later"
  head "https://github.com/adelie-ai/voice.git", branch: "main"

  # ALSA capture + D-Bus + systemd are Linux-only.
  depends_on :linux

  depends_on "cmake" => :build       # whisper-rs builds whisper.cpp; also aws-lc-rs
  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  depends_on "espeak-ng"             # phonemizer for the default Kokoro TTS backend
  depends_on "alsa-lib"              # microphone/speaker I/O via cpal

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/daemon")
    pkgshare.install "systemd" if Dir.exist?("systemd")
    pkgshare.install "scripts" if Dir.exist?("scripts")
  end

  def caveats
    <<~EOS
      adele-voice downloads its STT/TTS models on first setup (not bundled):
        adele-voice check-setup        # report which models/deps are present

      Model fetch helpers live in the source tree (just init-kokoro / just models),
      and a copy of scripts/ is under #{opt_pkgshare}/scripts. Models land in
      ~/.local/share/adele-voice/models. The wake word (.rpw) must be recorded
      locally.

      systemd user unit reference: #{opt_pkgshare}/systemd. Install it like:
        mkdir -p ~/.config/systemd/user
        sed 's#%h/.cargo/bin/adele-voice#'#{opt_bin}'/adele-voice#' \\
          #{opt_pkgshare}/systemd/adele-voice.service \\
          > ~/.config/systemd/user/adele-voice.service
        systemctl --user daemon-reload
        systemctl --user enable --now adele-voice

      Optional backends: piper (local fallback) and AWS Polly (cloud, opt-in).
    EOS
  end

  test do
    assert_path_exists bin/"adele-voice"
  end
end
