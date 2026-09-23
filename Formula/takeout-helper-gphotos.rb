class TakeoutHelperGphotos < Formula
  desc "Organize Google Photos Takeout archives"
  homepage "https://github.com/shoon/takeout-helper-gphotos"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.3/takeout-helper-gphotos-v0.1.3-macos-arm64.tar.gz"
      sha256 "f71ded8e6400e12ed66b0fab62ecf05644226e6a0f38acc9334b326156b4e26e"
    else
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.3/takeout-helper-gphotos-v0.1.3-macos-x64.tar.gz"
      sha256 "db8bb11353d25a602816a6349fd3f2aee3ef48797e0b28f6c7568b27978f29c6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.3/takeout-helper-gphotos-v0.1.3-linux-arm64.tar.gz"
      sha256 "e978b90ad2120d32e66841c6febc129743039a1deace54b5e399e8bdab8c3cce"
    else
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.3/takeout-helper-gphotos-v0.1.3-linux-x64.tar.gz"
      sha256 "95ce685d56ccdcf05511d05f296acb20ed89a3c636508aeec5d5068e22b89659"
    end
  end

  def install
    bin.install "takeout-helper-gphotos"
    doc.install "README.md", "CHANGELOG.md", "NOTICE", "SECURITY.md", "THIRD_PARTY_NOTICES.txt", "TRADEMARKS.md"
    doc.install Dir["docs/*.md"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/takeout-helper-gphotos --version")
  end
end
