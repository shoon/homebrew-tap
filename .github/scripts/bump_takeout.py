#!/usr/bin/env python3
"""Stage a verified takeout-helper-gphotos formula update.

`brew bump` cannot update this formula because its URLs live inside
on_macos/on_linux blocks ("Could not find 'url' stanza!"). This script does the
same job for the four platform archives:

* takes the latest published stable release (never a draft or prerelease),
* only ever moves the version forward,
* downloads every archive and requires its SHA-256 to match the release's
  SHA256SUMS.txt,
* requires each archive to contain the binary and every document the formula
  installs, and
* rewrites only the URL and sha256 lines.

It writes the formula in place and prints the new version on stdout (nothing
when already current). It never commits, pushes, or calls a write API.
"""
import hashlib
import json
import os
import re
import sys
import tarfile
import tempfile
import urllib.request
from pathlib import Path

REPO = "shoon/takeout-helper-gphotos"
NAME = "takeout-helper-gphotos"
FORMULA = Path("Formula/takeout-helper-gphotos.rb")
PLATFORMS = ("macos-arm64", "macos-x64", "linux-arm64", "linux-x64")
STABLE_TAG = re.compile(r"^v(\d+)\.(\d+)\.(\d+)$")
URL_LINE = re.compile(
    r'^(?P<indent>\s*)url "https://github\.com/shoon/takeout-helper-gphotos/releases/download/'
    r'v(?P<version>[^/]+)/takeout-helper-gphotos-v(?P=version)-(?P<platform>[a-z0-9-]+)\.tar\.gz"$')
SHA_LINE = re.compile(r'^(?P<indent>\s*)sha256 "[0-9a-f]{64}"$')
# Everything Formula#install copies; docs/*.md must also be non-empty.
REQUIRED = {NAME, "README.md", "CHANGELOG.md", "NOTICE", "SECURITY.md", "THIRD_PARTY_NOTICES.txt", "TRADEMARKS.md"}


class Refused(Exception):
    pass


def require(condition, message):
    if not condition:
        raise Refused(message)


def fetch(url, accept=None):
    headers = {"User-Agent": "shoon-homebrew-tap-bump"}
    if accept:
        headers["Accept"] = accept
    token = os.environ.get("GH_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        headers["Authorization"] = "Bearer " + token
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=120) as response:
        return response.read()


def version_key(version):
    match = STABLE_TAG.match("v" + version)
    require(match is not None, f"Not a stable version: {version}")
    return tuple(int(part) for part in match.groups())


def parse_sums(text):
    sums = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        match = re.fullmatch(r"([0-9a-f]{64}) [ *]?(\S+)", line.strip())
        require(match is not None, f"Malformed SHA256SUMS.txt line: {line!r}")
        require(match[2] not in sums, f"Duplicate checksum entry: {match[2]}")
        sums[match[2]] = match[1]
    return sums


def check_archive(path, version, platform):
    root = f"{NAME}-v{version}-{platform}/"
    with tarfile.open(path, "r:gz") as archive:
        members = {m.name: m for m in archive.getmembers()}
    for name in members:
        require(name == root.rstrip("/") or name.startswith(root), f"{path.name}: unexpected path {name}")
        require(".." not in Path(name).parts and not name.startswith("/"), f"{path.name}: unsafe path {name}")
    for name in REQUIRED:
        member = members.get(root + name)
        require(member is not None and member.isfile(), f"{path.name}: missing {name}")
    require(members[root + NAME].mode & 0o111, f"{path.name}: binary is not executable")
    require(any(n.startswith(root + "docs/") and n.endswith(".md") and members[n].isfile() for n in members),
            f"{path.name}: missing docs/*.md")


def rewrite(formula, version, hashes):
    lines = formula.split("\n")
    seen = set()
    for index, line in enumerate(lines):
        match = URL_LINE.match(line)
        if not match:
            continue
        platform = match["platform"]
        require(platform in hashes and platform not in seen, f"Unexpected or repeated platform {platform}")
        sha = SHA_LINE.match(lines[index + 1]) if index + 1 < len(lines) else None
        require(sha is not None, f"No sha256 line after the {platform} url")
        seen.add(platform)
        lines[index] = (f'{match["indent"]}url "https://github.com/{REPO}/releases/download/'
                        f'v{version}/{NAME}-v{version}-{platform}.tar.gz"')
        lines[index + 1] = f'{sha["indent"]}sha256 "{hashes[platform]}"'
    require(seen == set(PLATFORMS), f"Formula platforms {sorted(seen)} != {sorted(PLATFORMS)}")
    return "\n".join(lines)


def current_version(formula):
    versions = {m["version"] for m in map(URL_LINE.match, formula.split("\n")) if m}
    require(len(versions) == 1, f"Formula URLs disagree on version: {sorted(versions)}")
    return versions.pop()


def main():
    formula = FORMULA.read_text(encoding="utf-8")
    current = current_version(formula)
    release = json.loads(fetch(f"https://api.github.com/repos/{REPO}/releases/latest", "application/vnd.github+json"))
    require(not release["draft"] and not release["prerelease"], "Latest release is not a published stable release")
    tag = release["tag_name"]
    require(STABLE_TAG.match(tag) is not None, f"Latest release tag {tag!r} is not vMAJOR.MINOR.PATCH")
    version = tag[1:]
    if version_key(version) <= version_key(current):
        print(f"{NAME} {current} is current (latest stable {version}).", file=sys.stderr)
        return
    base = f"https://github.com/{REPO}/releases/download/{tag}/"
    sums = parse_sums(fetch(base + "SHA256SUMS.txt").decode("utf-8"))
    hashes = {}
    with tempfile.TemporaryDirectory() as temp:
        for platform in PLATFORMS:
            filename = f"{NAME}-v{version}-{platform}.tar.gz"
            require(filename in sums, f"SHA256SUMS.txt has no entry for {filename}")
            path = Path(temp) / filename
            path.write_bytes(fetch(base + filename))
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            require(digest == sums[filename], f"{filename}: SHA-256 {digest} does not match SHA256SUMS.txt")
            check_archive(path, version, platform)
            hashes[platform] = digest
            print(f"Verified {filename} {digest}", file=sys.stderr)
    FORMULA.write_text(rewrite(formula, version, hashes), encoding="utf-8")
    print(version)


if __name__ == "__main__":
    try:
        main()
    except Refused as error:
        print(f"Refused: {error}", file=sys.stderr)
        sys.exit(1)
