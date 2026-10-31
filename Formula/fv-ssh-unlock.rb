class FvSshUnlock < Formula
  desc "Monitor and unlock FileVault-protected Macs over SSH"
  homepage "https://github.com/shoon/fv-ssh-unlock"
  url "https://github.com/shoon/fv-ssh-unlock/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "046842f38b654141fbf4fb8ee379e368215ec015e8dad54e1669a7a704975bf1"
  license "Apache-2.0"
  head "https://github.com/shoon/fv-ssh-unlock.git", branch: "main"

  bottle do
    root_url "https://github.com/shoon/homebrew-tap/releases/download/fv-ssh-unlock-0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "cf4cc159633b5fce680889ce7f79da8bd54346e2d040c765d28574dfe7858cd2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d24e0d383153f7613db33641f3c46476651415c951fa4f0e7dacf989a4e01438"
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
