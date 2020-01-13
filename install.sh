#!/bin/sh
PKG_URL="https://github.com/x1unix/telshell"
URL_DOWNLOAD_PREFIX="https://${PKG_URL}/releases/latest/download"
ISSUE_URL="https://${PKG_URL}/issues"
NIL="nil"
PATH="${PATH}"

RED="\033[0;31m"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

warn() {
    printf "${YELLOW}${1}${NC}\n"
}

panic() {
    printf "${RED}ERROR: ${1}${NC}\n" >&2
    printf "${RED}Installation Failed${NC}\n"
    exit 1
}

get_bin_name() {
    os=$(uname -s | awk '{print tolower($0)}')
    arc=$(get_arch)
    if [ "${arc}" = "${NIL}" ]; then
        echo "${NIL}"
    else
        echo "telshell_${os}-${arc}"
    fi
}

get_arch() {
    a=$(uname -m)
    case ${a} in
    "x86_64" | "amd64" )
        echo "amd64"
        ;;
    "i386" | "i486" | "i586")
        echo "i386"
        ;;
    *)
        echo ${NIL}
        ;;
    esac
}


main() {
    local gb_name=$(get_bin_name)
    if [ "$gb_name" = "$NIL" ]; then
        panic "No prebuilt binaries available, try to check out release for your platform at https://${PKG_URL}/releases"
    fi

    local download_dir="${HOME}/bin"
    mkdir -p ${download_dir}

    local dest_file="${download_dir}/gilbert"
    local lnk=${URL_DOWNLOAD_PREFIX}/${gb_name}
    echo "-> Downloading '${lnk}'..."
    if ! curl -sS -L -o "${dest_file}" ${lnk}; then
        warn "Installation failed, failed to download binary"
        exit 1
    fi

    chmod +x ${dest_file}
    echo "-> Successfully installed to '${dest_file}'"
    printf "${GREEN}Done!${NC}\n"
    exit 0
}

main