#!/usr/bin/env bash

# asdf env vars:
# ASDF_INSTALL_TYPE : version or ref
# ASDF_INSTALL_VERSION : full version number or git ref
# ASDF_INSTALL_PATH : where the tool should be
# ASDF_CONCURRENCY : number of cores
# ASDF_DOWNLOAD_PATH : where bin/download downloads to
# ASDF_PLUGIN_PATH : where the plugin is installed
# ASDF_PLUGIN_SOURCE_URL : url of the plugin
# ASDF_PLUGIN_PREV_REF : previous git-ref of plugin
# ASDF_PLUGIN_POST_REF : updated git-ref of plugin
# ASDF_CMD_FILE : full path of file being sourced

set -euo pipefail

GH_REPO="https://github.com/jgrey4296/asdf-texlive.git"
TOOL_NAME="texlive"
TOOL_TEST="tlmgr --help"
BIN_DIR="bin/x86_64-linux"

# TODO: list versions from here, and then download the respective instal-tl-unx.tar.gz
TEXLIVE_ARCHIVE="https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/"
INSTALL_SCRIPT="install-tl-unx"
INSTALL_SCRIPT_URL="https://mirror.ctan.org/systems/texlive/tlnet"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if <YOUR TOOL> is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

function sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

function list_all_versions() {
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	echo "2025"
}

function download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url="$INSTALL_SCRIPT_URL/$filename"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$ASDF_DOWNLOAD_PATH/$filename" -C - "$url" || fail "Could not download $url"

}

function install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="$3"


	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	# if texuserdir is set else:
	TEXUSERDIR="$XDG_CONFIG_HOME/texlive"

	(
		mkdir -p "$install_path/user/texmf-var"


		perl "$ASDF_DOWNLOAD_PATH/$INSTALL_SCRIPT" \
		--no-interaction \
		-scheme=minimal \
		-texdir "$install_path" \
		-texmflocal "$install_path/texmf-local" \
		-texmfsysvar "$install_path/texmf-var" \
		-texmfsysconfig "$install_path/texmf-config" \
		-texmfhome "$install_path/user" \
		-texmfvar "$install_path/user/texmf-var" \
		-texmfconfig "$TEXUSERDIR"


		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$BIN_DIR/$tool_cmd" || fail "Expected $install_path/$BIN_DIR/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
