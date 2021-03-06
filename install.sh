#!/bin/sh
PKG_URL="github.com/x1unix/telshell"
URL_DOWNLOAD_PREFIX="https://${PKG_URL}/releases/latest/download"
ISSUE_URL="https://${PKG_URL}/issues"

OS=$(uname -s | awk '{print tolower($0)}')
ARCH=$(uname -m)

RED="\033[0;31m"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

warn() {
    printf "${YELLOW}${1}${NC}\n"
}

panic() {
    printf "${RED}ERROR: ${1}${NC}\n" >&2
    printf "${RED}\nIf you feel that this is an installer issue, you may submit an issue on ${ISSUE_URL}\nInstallation failed. ${NC}\n"
    exit 1
}

is_windows() {
  case ${OS} in
    cygwin*|mingw32*|msys*|mingw*)
      return 0
      ;;
    *)
      return 1
      ;;
    esac
}

get_download_url() {
    arc=$(get_arch)
    os="$OS"

    if is_windows; then
      file_suffix=.exe  # Set .exe as executable suffix
      os=windows        # Override os to Windows for MinGW, MSYS, etc
    fi
    echo "${URL_DOWNLOAD_PREFIX}/telshell_${os}-${arc}${file_suffix}"
}

get_arch() {
    case $ARCH in
    "x86_64" | "amd64" )
      echo "amd64"
      ;;
    "i386" | "i486" | "i586" | "i686")
      echo "i386"
      ;;
    *)
      echo "$ARCH"
      ;;
    esac
}

main() {
    download_dir="${HOME}/bin"
    mkdir -p "${download_dir}"

    dest_file="${download_dir}/telshell"
    if is_windows; then
      dest_file="${dest_file}.exe"
    fi

    download_url=$(get_download_url)
    echo "-> Downloading '${download_url}'..."
    http_status=$(curl --fail --write-out "%{http_code}" -L --show-error --progress -o "${dest_file}" "${download_url}")
    case ${http_status} in
    "200")
      chmod +x "${dest_file}"
      echo "-> Successfully installed to '${dest_file}'"
      printf "${GREEN}Done!${NC}\n"
      exit 0
      ;;
    "404")
      sys_label="${OS} ${ARCH}"
      panic "No prebuilt binaries available for ${sys_label}, try to check out release for your platform at https://${PKG_URL}/releases"
      ;;
    *)
      panic "Installation failed, failed to download binary (HTTP error ${http_status})"
      ;;
    esac
}

main