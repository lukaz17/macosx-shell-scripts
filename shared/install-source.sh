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
		bun) echo "oven-sh" ;;
		localai) echo "mudler" ;;
		nodejs) echo "" ;;
		opencode) echo "anomalyco" ;;
		pnpm) echo "pnpm" ;;
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
		bun) echo "bun" ;;
		localai) echo "LocalAI" ;;
		nodejs) echo "" ;;
		opencode) echo "opencode" ;;
		pnpm) echo "pnpm" ;;
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
		bun)
			echo "https://github.com/oven-sh/bun/releases/download/bun-v${_install_version}/bun-darwin-x64.zip" ;;
		localai)
			echo "" ;;
		nodejs)
			echo "https://nodejs.org/dist/v${_install_version}/node-v${_install_version}-darwin-x64.tar.gz" ;;
		opencode)
			if is_version_at_least "${_install_version}" "2"; then
				echo "https://opencode.ai/files/bin/${_install_version}/opencode-darwin-x64.zip"
			else
				echo "https://github.com/anomalyco/opencode/releases/download/v${_install_version}/opencode-darwin-x64.zip"
			fi ;;
		pnpm)
			if is_version_at_least "${_install_version}" "11"; then
				echo "https://github.com/pnpm/pnpm/releases/download/v${_install_version}/pnpm-darwin-x64.tar.gz"
			else
				echo "https://github.com/pnpm/pnpm/releases/download/v${_install_version}/pnpm-macos-x64"
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
		bun)
			echo "https://github.com/oven-sh/bun/releases/download/bun-v${_install_version}/bun-darwin-aarch64.zip" ;;
		localai)
			echo "https://github.com/mudler/LocalAI/releases/download/v${_install_version}/local-ai-v${_install_version}-darwin-arm64" ;;
		nodejs)
			if is_version_at_least "${_install_version}" "16.0.0"; then
				echo "https://nodejs.org/dist/v${_install_version}/node-v${_install_version}-darwin-arm64.tar.gz"
			else
				echo ""
			fi ;;
		opencode)
			if is_version_at_least "${_install_version}" "2"; then
				echo "https://opencode.ai/files/bin/${_install_version}/opencode-darwin-arm64.zip"
			else
				echo "https://github.com/anomalyco/opencode/releases/download/v${_install_version}/opencode-darwin-arm64.zip"
			fi ;;
		pnpm)
			if is_version_at_least "${_install_version}" "11"; then
				echo "https://github.com/pnpm/pnpm/releases/download/v${_install_version}/pnpm-darwin-arm64.tar.gz"
			else
				echo "https://github.com/pnpm/pnpm/releases/download/v${_install_version}/pnpm-macos-arm64"
			fi ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${_install_version}/uv-aarch64-apple-darwin.tar.gz" ;;
		*) echo "" ;;
	esac
}
