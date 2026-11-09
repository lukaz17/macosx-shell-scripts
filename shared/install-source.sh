#!/bin/sh

################################################################################
#
#  install-source
#  Libraries to support *-install scripts
#
#  MIT License.
#  Copyright (C) 2025 Nguyen Nhat Tung.
#
################################################################################

set +x

# ------------------------------------------------------------------------------
# Return the GitHub owner for a Program ID.
# ------------------------------------------------------------------------------
get_source_owner() {
	_program_id="${1}"
	case "${_program_id}" in
		localai) echo "mudler" ;;
		opencode) echo "anomalyco" ;;
		uv) echo "astral-sh" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the GitHub repository for a Program ID.
# ------------------------------------------------------------------------------
get_source_repo() {
	_program_id="${1}"
	case "${_program_id}" in
		localai) echo "LocalAI" ;;
		opencode) echo "opencode" ;;
		uv) echo "uv" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the download URI for AMD64 for a Program ID.
# ------------------------------------------------------------------------------
get_download_uri_amd64() {
	_program_id="${1}"
	_install_version="${2}"
	case "${_program_id}" in
		localai)
			echo "" ;;
		opencode)
			if is_version_at_least "${_install_version}" "2"; then
				echo "https://opencode.ai/files/bin/${_install_version}/opencode-darwin-x64.zip"
			else
				echo "https://github.com/anomalyco/opencode/releases/download/v${_install_version}/opencode-darwin-x64.zip"
			fi ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${_install_version}/uv-x86_64-apple-darwin.tar.gz" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the download URI for ARM64 for a Program ID.
# ------------------------------------------------------------------------------
get_download_uri_arm64() {
	_program_id="${1}"
	_install_version="${2}"
	case "${_program_id}" in
		localai)
			echo "https://github.com/mudler/LocalAI/releases/download/v${_install_version}/local-ai-v${_install_version}-darwin-arm64" ;;
		opencode)
			if is_version_at_least "${_install_version}" "2"; then
				echo "https://opencode.ai/files/bin/${_install_version}/opencode-darwin-arm64.zip"
			else
				echo "https://github.com/anomalyco/opencode/releases/download/v${_install_version}/opencode-darwin-arm64.zip"
			fi ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${_install_version}/uv-aarch64-apple-darwin.tar.gz" ;;
		*) echo "" ;;
	esac
}
