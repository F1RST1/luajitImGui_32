#!/usr/bin/env bash
set -euo pipefail

readonly archive_base="https://repo.msys2.org/mingw/mingw32"
readonly mingw_root="${MINGW_ROOT:-/mingw32}"
readonly download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT

install_archived_package() {
  local package="$1"
  local sha256="$2"
  local archive="$download_dir/$package"

  curl --fail --location --retry 3 --silent --show-error \
    "$archive_base/$package" --output "$archive"
  echo "$sha256  $archive" | sha256sum --check --status || {
    echo "SHA-256 verification failed for $package" >&2
    return 1
  }

  mkdir -p "$mingw_root"
  tar --zstd --extract --file="$archive" --directory="$mingw_root" \
    --strip-components=1
}

install_archived_package \
  mingw-w64-i686-brotli-1.2.1-1-any.pkg.tar.zst \
  9d77801e759791028fb9d744b6c6d60bdd9301a4d32838d7d0e155688a601bd6
install_archived_package \
  mingw-w64-i686-bzip2-1.0.8-4-any.pkg.tar.zst \
  388da015be5064f46ca2442d4beecf7cae47b3c56c71702ae72a8eceaad1f845
install_archived_package \
  mingw-w64-i686-zlib-1.4-2-any.pkg.tar.zst \
  d388d6147ef523b06fbea758f130cfed821818749f9364a4bf21554732110f10
install_archived_package \
  mingw-w64-i686-freetype-2.15.0-1-any.pkg.tar.zst \
  527edf8bc431e9e436f1c9b74fbab01b4646b0c725bd6f9523bd73189b61e5c4
install_archived_package \
  mingw-w64-i686-harfbuzz-15.1.0-1-any.pkg.tar.zst \
  1e4efef909ffe8288f7ddea8bdaf285f1318f16a8ee3720040d2be994a4292d7
install_archived_package \
  mingw-w64-i686-graphite2-1.3.15-1-any.pkg.tar.zst \
  534a747d88e974291212e2abe5f35393fcffa9620311418b07af2a894daaf5bc
install_archived_package \
  mingw-w64-i686-libpng-1.6.59-2-any.pkg.tar.zst \
  c61389643dc032d6460547fc32d72f6b7df1973eda93927f0eab3b900a28bc47
install_archived_package \
  mingw-w64-i686-libsamplerate-0.2.2-1-any.pkg.tar.zst \
  027a6f6b885d8c0d02fc3b16233b7cc5f508d6c17dfed3fa030c12f8746707d8
install_archived_package \
  mingw-w64-i686-stb-r2216.f1c79c0-1-any.pkg.tar.zst \
  0987b619736210ae79b506a3036877caf6bd01171a71ce1e762c325f67547193
