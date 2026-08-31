class FvSshUnlock < Formula
  desc "Monitor and unlock FileVault-protected Macs over SSH"
  homepage "https://github.com/shoon/fv-ssh-unlock"
  url "https://github.com/shoon/fv-ssh-unlock/archive/refs/tags/v0.2.0-rc.2.tar.gz"
  sha256 "6e2091ff61248fd9d65763d94b3495b2c27336a19455147acc41debecb3cc427"
  license "Apache-2.0"
  head "https://github.com/shoon/fv-ssh-unlock.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = "-s -w -buildid= -X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags, tags: "keyring"),
           "-trimpath", "./cmd/fv-ssh-unlock"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fv-ssh-unlock --version")
    assert_match '"providers"', shell_output("#{bin}/fv-ssh-unlock credentials providers --json")
  end
end
