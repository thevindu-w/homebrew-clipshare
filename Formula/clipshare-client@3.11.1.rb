class ClipshareClientAT3111 < Formula
  desc "Lightweight tool for sharing clipboard across devices"
  homepage "https://github.com/thevindu-w/clip_share_desktop"
  url "https://github.com/thevindu-w/clip_share_desktop/releases/download/v3.11.1/clip_share_client-3.11.1-macos.zip"
  sha256 "2bd337557b4628aaca5fac65b305595650bc14791a1fc5334dd9070226e4b8e5"
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
