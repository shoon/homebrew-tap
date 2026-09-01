class TakeoutHelperGphotos < Formula
  desc "Organize Google Photos Takeout archives"
  homepage "https://github.com/shoon/takeout-helper-gphotos"
  version "0.1.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.2/takeout-helper-gphotos-v0.1.2-macos-arm64.tar.gz"
      sha256 "7658f10fa97d67da27a7ed1f8fb2f9e59f36c72e680c980d16d7962382ce112a"
    else
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.2/takeout-helper-gphotos-v0.1.2-macos-x64.tar.gz"
      sha256 "d6defe0228dd85f35d157a017977e01ca916a2a0ee15918b466528bd3383efe7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.2/takeout-helper-gphotos-v0.1.2-linux-arm64.tar.gz"
      sha256 "6280b68b28d84e6c0da7b4a20c1721b5ee5ad74e9c8c2b8a481ff1bcb84df6d9"
    else
      url "https://github.com/shoon/takeout-helper-gphotos/releases/download/v0.1.2/takeout-helper-gphotos-v0.1.2-linux-x64.tar.gz"
      sha256 "ed793cf5dde4a5428b94d6d2b7e0f58dd75542fb0dac434ca85f37a8f244d9f7"
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
