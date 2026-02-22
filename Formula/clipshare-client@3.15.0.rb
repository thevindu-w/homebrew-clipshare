class ClipshareClientAT3150 < Formula
  desc "Lightweight tool for sharing clipboard across devices"
  homepage "https://github.com/thevindu-w/clip_share_desktop"
  url "https://github.com/thevindu-w/clip_share_desktop/releases/download/v3.15.0/clip_share_client-3.15.0-macos.zip"
  sha256 "c628aae0e4a45a9eadffbf7d87a5cc8a504ce2976d801a1b38f187d51979808b"
  license "GPL-3.0-or-later"

  depends_on "libunistring"
  depends_on "openssl@3"

  def install
    arch = Hardware::CPU.intel? ? "x86_64" : "arm64"
    bin.install "clip-share-client-#{arch}" => "clip-share-client"
    (bin/"clipshare-client-initconf").write <<~EOS
      #!/bin/bash
      set -e
      cd
      export HOME="$(pwd)"
      CONF_PATHS=("$XDG_CONFIG_HOME" "${HOME}/.config" "$HOME")
      for directory in "${CONF_PATHS[@]}"; do
        [ -d "$directory" ] || continue
        conf_path="${directory}/clipshare-desktop.conf"
        if [ -f "$conf_path" ] && [ -r "$conf_path" ]; then
          CONF_DIR="$directory"
          break
        fi
      done
      for directory in "${CONF_PATHS[@]}"; do
        [ -n "$CONF_DIR" ] && break
        if [ -d "$directory" ] && [ -w "$directory" ]; then
          CONF_DIR="$directory"
        fi
      done
      if [ -z "$CONF_DIR" ]; then
        echo "Error: Could not find a directory for the configuration file!"
        exit 1
      fi
      CONF_FILE="${CONF_DIR}/clipshare-desktop.conf"
      if [ ! -f "$CONF_FILE" ]; then
        mkdir -p ~/Downloads
        echo "working_dir=${HOME}/Downloads" >"$CONF_FILE"
        echo "Created a new configuration file $CONF_FILE"
      else
        echo "Config file already exists at $CONF_FILE"
      fi
    EOS
  end

  def caveats
    <<~EOF
      A helper script is available to create a default config for clipshare-client:

        clipshare-client-initconf

      It will create a clipshare-desktop.conf file with default settings if it doesn't exist.
    EOF
  end

  test do
    system "#{bin}/clip-share-client", "-v"
  end

  service do
    run [opt_bin/"clip-share-client", "-D"]
    keep_alive true
    working_dir "#{ENV["HOME"]}"
    log_path var/"log/clip_share_client.log"
    error_log_path var/"log/clip_share_client-error.log"
  end
end
