#!/usr/bin/env bash
set -euo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$DIR"

if [[ ! -f /etc/debian_version ]]; then
	echo "bootstrap.sh supports Debian-family systems." >&2
	exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
	SUDO=()
else
	SUDO=(sudo)
fi

HOMEDIR=$HOME
USERNAME=$(id -un)
GROUP=$(id -gn)

usage() {
	cat <<'EOF'
Usage: ./bootstrap.sh [core|dev|desktop|fonts|<state>]

  ./bootstrap.sh
      Apply the core, dev, and desktop roles.

  ./bootstrap.sh core dev
      Apply the named roles.

  ./bootstrap.sh fonts
      Install Fira Code 6.2 and Meslo Nerd Font 3.5.1.

  ./bootstrap.sh git
      Apply a single Salt state.
EOF
}

is_role() {
	case "$1" in
		core|dev|desktop) return 0 ;;
		*) return 1 ;;
	esac
}

MODE="highstate"
ROLES=(core dev desktop)
SLS=""

if [[ $# -eq 1 && "$1" == "--help" ]]; then
	usage
	exit 0
elif [[ $# -eq 1 && "$1" == "fonts" ]]; then
	MODE="fonts"
elif [[ $# -gt 0 ]]; then
	ROLES=()
	for arg in "$@"; do
		if is_role "$arg"; then
			ROLES+=("$arg")
		else
			MODE="sls"
			break
		fi
	done
	if [[ "$MODE" == "sls" ]]; then
		if [[ $# -ne 1 ]]; then
			echo "Pass one state name, or one or more roles (core, dev, desktop)." >&2
			exit 1
		fi
		SLS=$1
		ROLES=()
	fi
fi

ensure_packages() {
	local missing=()
	command -v curl >/dev/null 2>&1 || missing+=(curl)
	command -v wget >/dev/null 2>&1 || missing+=(wget)
	command -v unzip >/dev/null 2>&1 || missing+=(unzip)
	command -v gpg >/dev/null 2>&1 || missing+=(gnupg)
	command -v python3 >/dev/null 2>&1 || missing+=(python3)
	if ((${#missing[@]} > 0)); then
		echo "Installing ${missing[*]}"
		"${SUDO[@]}" apt-get update
		"${SUDO[@]}" apt-get install -y ca-certificates "${missing[@]}"
	fi
}

install_fonts() {
	local dest="${XDG_DATA_HOME:-$HOME/.local/share/fonts}"
	local tmp fira_version nerd_version
	fira_version="6.2"
	nerd_version="v3.5.1"
	mkdir -p "$dest"
	tmp=$(mktemp -d)
	trap 'rm -rf "$tmp"' RETURN

	echo "Installing Fira Code ${fira_version} and Meslo Nerd Font ${nerd_version}"
	wget -q -O "$tmp/FiraCode.zip" "https://github.com/tonsky/FiraCode/releases/download/${fira_version}/Fira_Code_v${fira_version}.zip"
	wget -q -O "$tmp/Meslo.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/${nerd_version}/Meslo.zip"
	unzip -q "$tmp/FiraCode.zip" -d "$tmp/firacode"
	unzip -q "$tmp/Meslo.zip" -d "$tmp/meslo"
	find "$tmp/firacode" "$tmp/meslo" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp -f {} "$dest/" \;

	if ! command -v fc-cache >/dev/null 2>&1; then
		"${SUDO[@]}" apt-get install -y fontconfig
	fi
	fc-cache -f "$dest"
	echo "Fonts installed in ${dest}"
}

install_salt() {
	if command -v salt-call >/dev/null 2>&1; then
		return
	fi

	echo "Installing Salt 3008 LTS"
	"${SUDO[@]}" mkdir -p -m 755 /etc/apt/keyrings
	curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
		| gpg --dearmor \
		| "${SUDO[@]}" tee /etc/apt/keyrings/salt-archive-keyring.pgp >/dev/null
	curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources \
		| "${SUDO[@]}" tee /etc/apt/sources.list.d/salt.sources >/dev/null
	printf '%s\n' 'Package: salt-*' 'Pin: version 3008.*' 'Pin-Priority: 1001' \
		| "${SUDO[@]}" tee /etc/apt/preferences.d/salt-pin-1001 >/dev/null
	"${SUDO[@]}" apt-get update
	"${SUDO[@]}" apt-get install -y salt-minion
	if command -v systemctl >/dev/null 2>&1; then
		"${SUDO[@]}" systemctl disable --now salt-minion || true
	fi
}

set_grains() {
	local roles_csv="" grains_json ssh_key oscodename
	if [[ -f "$HOMEDIR/.ssh/id_ed25519" ]]; then
		ssh_key="$HOMEDIR/.ssh/id_ed25519"
	elif [[ -f "$HOMEDIR/.ssh/id_rsa" ]]; then
		ssh_key="$HOMEDIR/.ssh/id_rsa"
	else
		ssh_key="$HOMEDIR/.ssh/id_ed25519"
	fi

	# shellcheck disable=SC1091
	source /etc/os-release
	oscodename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
	if [[ -z "$oscodename" ]]; then
		echo "Could not determine the OS codename from /etc/os-release" >&2
		exit 1
	fi

	if [[ $# -gt 0 ]]; then
		roles_csv=$(IFS=,; echo "$*")
	fi

	grains_json=$(
		USERNAME="$USERNAME" \
		GROUP="$GROUP" \
		HOMEDIR="$HOMEDIR" \
		STATEROOT="$DIR/states" \
		SSH_KEY_PATH="$ssh_key" \
		OSCODENAME="$oscodename" \
		ROLES_CSV="$roles_csv" \
		python3 - <<'PY'
import json
import os

roles = [role for role in os.environ.get("ROLES_CSV", "").split(",") if role]
payload = {
    "user": os.environ["USERNAME"],
    "group": os.environ["GROUP"],
    "homedir": os.environ["HOMEDIR"],
    "stateroot": os.environ["STATEROOT"],
    "sshkey": os.environ["SSH_KEY_PATH"],
    "oscodename": os.environ["OSCODENAME"],
}
if roles:
    payload["roles"] = roles
print(json.dumps(payload))
PY
	)

	"${SUDO[@]}" salt-call --local --config-dir="$DIR" --state-output=changes grains.setvals "$grains_json"
}

ensure_packages

if [[ "$MODE" == "fonts" ]]; then
	install_fonts
	exit 0
fi

install_salt
set_grains "${ROLES[@]}"

if [[ "$MODE" == "highstate" ]]; then
	echo "Applying roles: ${ROLES[*]}"
	"${SUDO[@]}" salt-call \
		--local \
		--config-dir="$DIR" \
		--state-output=mixed \
		--retcode-passthrough \
		state.highstate
else
	echo "Applying state ${SLS}"
	"${SUDO[@]}" salt-call \
		--local \
		--config-dir="$DIR" \
		--state-output=mixed \
		--retcode-passthrough \
		state.apply "$SLS"
fi
