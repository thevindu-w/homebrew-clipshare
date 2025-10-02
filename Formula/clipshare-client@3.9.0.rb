class ClipshareClientAT390 < Formula
  desc "Lightweight tool for sharing clipboard across devices"
  homepage "https://github.com/thevindu-w/clip_share_desktop"
  url "https://github.com/thevindu-w/clip_share_desktop/releases/download/v3.9.0/clip_share_client-3.9.0-macos.zip"
  sha256 "823fdbd4ba7bb7079266e7d64b80e1519c81c2a090b46b24eea7089ab8085e12"
  license "GPL-3.0-or-later"

  depends_on "libunistring"
  depends_on "openssl@3"

  def install
    arch = Hardware::CPU.intel? ? "x86_64" : "arm64"
    bin.install "clip-share-client-#{arch}" => "clip-share-client"
    (bin/"clipshare-client-initconf").write <<~EOS
      #!/bin/bash
      cd
      export HOME="$(pwd)"
      CONF_FILE="${HOME}/clipshare-desktop.conf"
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
      A helper script is available to create a default config in your home directory:

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
