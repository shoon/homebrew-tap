class TakeoutHelperGphotos < Formula
  desc "Organize Google Photos Takeout archives"
  homepage "https://github.com/shoon/takeout-helper-gphotos"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.4/takeout-helper-gphotos-v0.1.4-macos-arm64.tar.gz"
      sha256 "1081f0b8b99bd8805c9de6c6bf4971fe1180a1a2e80ebe047c7aa44c489c079c"
    else
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.4/takeout-helper-gphotos-v0.1.4-macos-x64.tar.gz"
      sha256 "6a2809a9b6590a0c5e8c843984fa7dacef08a5ad785d0e6e82209c0e64d7563d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.4/takeout-helper-gphotos-v0.1.4-linux-arm64.tar.gz"
      sha256 "591aabd3967509b6c7d2c5a0b084b56b3a1e1974f8c39108c0d60d19594cf9d1"
    else
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.4/takeout-helper-gphotos-v0.1.4-linux-x64.tar.gz"
      sha256 "2b541b75e3db2c663dba409a50b11a73aa8910c044c8eed90d8cd218addd73ea"
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
