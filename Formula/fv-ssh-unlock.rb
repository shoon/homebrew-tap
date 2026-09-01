class FvSshUnlock < Formula
  desc "Monitor and unlock FileVault-protected Macs over SSH"
  homepage "https://github.com/shoon/fv-ssh-unlock"
  url "https://github.com/shoon/fv-ssh-unlock/archive/refs/tags/v0.2.0-rc.3.tar.gz"
  sha256 "a2bf9f8b6e76e89f4f027528d76b9cd55f915b8096c4657f1754722bb47b876c"
  license "Apache-2.0"
  head "https://github.com/shoon/fv-ssh-unlock.git", branch: "main"

  bottle do
    root_url "https://github.com/shoon/homebrew-tap/releases/download/fv-ssh-unlock-0.2.0-rc.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "9d297af4403e11dbdec3cae3ab5df42cfe289e740fd6a90c5cf50788d5fce955"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1a6f2a9639fff7c49c2cb3672232320ca45e595ab9dcf24f6aba695e4d7ab084"
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
