class ClipshareServerAT3112 < Formula
  desc "Lightweight tool for sharing clipboard across devices"
  homepage "https://github.com/thevindu-w/clip_share_server"
  url "https://github.com/thevindu-w/clip_share_server/releases/download/v3.11.2/clip_share_server-3.11.2-macos.zip"
  sha256 "d8059dd3e5c60fc4aa2994e907657d2940b7d7ca66d2e257e12cc67277184362"
  license "GPL-3.0-or-later"

  depends_on "libpng"
  depends_on "libunistring"
  depends_on "openssl@3"

  def install
    arch = Hardware::CPU.intel? ? "x86_64" : "arm64"
    bin.install "clip_share-#{arch}" => "clip_share"
    (bin/"clipshare-initconf").write <<~EOS
      #!/bin/bash
      cd
      export HOME="$(pwd)"
      CONF_FILE="${HOME}/clipshare.conf"
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

        clipshare-initconf

      It will create a clipshare.conf file with default settings if it doesn't exist.
    EOF
  end

  test do
    system "#{bin}/clip_share", "-v"
  end

  service do
    run [opt_bin/"clip_share", "-D"]
    keep_alive true
    working_dir "#{ENV["HOME"]}"
    log_path var/"log/clip_share_server.log"
    error_log_path var/"log/clip_share_server-error.log"
  end
end
