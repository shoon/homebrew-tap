class FvSshUnlock < Formula
  desc "Monitor and unlock FileVault-protected Macs over SSH"
  homepage "https://github.com/shoon/fv-ssh-unlock"
  url "https://github.com/shoon/fv-ssh-unlock/archive/refs/tags/v0.2.0-rc.4.tar.gz"
  sha256 "b29c219dd51f60c8a6de1307f0769635166a52c00760dec101892ad9903a4095"
  license "Apache-2.0"
  head "https://github.com/shoon/fv-ssh-unlock.git", branch: "main"

  bottle do
    root_url "https://github.com/shoon/homebrew-tap/releases/download/fv-ssh-unlock-0.2.0-rc.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "cc437d964e1aa17f4f22eb34a9548895223809b6fcb151b14948fb431f05ec3c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "aeb648391f2de7ec5fa0df5b5b157589834ec723c334b45b6463b0c18a755ae1"
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
