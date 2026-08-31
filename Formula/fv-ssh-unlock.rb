class FvSshUnlock < Formula
  desc "Monitor and unlock FileVault-protected Macs over SSH"
  homepage "https://github.com/shoon/fv-ssh-unlock"
  url "https://github.com/shoon/fv-ssh-unlock/archive/refs/tags/v0.2.0-rc.2.tar.gz"
  sha256 "6e2091ff61248fd9d65763d94b3495b2c27336a19455147acc41debecb3cc427"
  license "Apache-2.0"
  head "https://github.com/shoon/fv-ssh-unlock.git", branch: "main"

  bottle do
    root_url "https://github.com/shoon/homebrew-tap/releases/download/fv-ssh-unlock-0.2.0-rc.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "6b336a0568100a85a0c135fdc070c436b8c2c316d81f43fd480998233b3ad64e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9281801c598bf69253376a259a7855d503feb7b33b5fc4595b776a69dc576f78"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = "-s -w -buildid= -X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags, tags: "keyring"),
           "-trimpath", "./cmd/fv-ssh-unlock"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fv-ssh-unlock --version")
    assert_match '"providers"', shell_output("#{bin}/fv-ssh-unlock credentials providers --json")
  end
end
