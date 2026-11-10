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
		firefox) echo "" ;;
		foundry) echo "foundry-rs" ;;
		go) echo "" ;;
		hugo) echo "gohugoio" ;;
		localai) echo "mudler" ;;
		nodejs) echo "" ;;
		opencode) echo "anomalyco" ;;
		pnpm) echo "pnpm" ;;
		telegram) echo "telegramdesktop" ;;
		uv) echo "astral-sh" ;;
		vscode) echo "microsoft" ;;
		waterfox) echo "BrowserWorks" ;;
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
		firefox) echo "" ;;
		foundry) echo "foundry" ;;
		go) echo "" ;;
		hugo) echo "hugo" ;;
		localai) echo "LocalAI" ;;
		nodejs) echo "" ;;
		opencode) echo "opencode" ;;
		pnpm) echo "pnpm" ;;
		telegram) echo "tdesktop" ;;
		uv) echo "uv" ;;
		vscode) echo "vscode" ;;
		waterfox) echo "waterfox" ;;
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
		firefox)
			echo "https://ftp.mozilla.org/pub/firefox/releases/${_install_version}/mac/en-US/Firefox%20${_install_version}.dmg" ;;
		foundry)
			echo "https://github.com/foundry-rs/foundry/releases/download/v${_install_version}/foundry_v${_install_version}_darwin_amd64.tar.gz" ;;
		go)
			echo "https://go.dev/dl/go${_install_version}.darwin-amd64.tar.gz" ;;
		hugo)
			echo "https://github.com/gohugoio/hugo/releases/download/v${_install_version}/hugo_extended_withdeploy_${_install_version}_darwin-universal.pkg" ;;
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
		telegram)
			if is_version_at_least "${_install_version}" "7.2.6"; then
				echo "https://github.com/telegramdesktop/tdesktop/releases/download/v${_install_version}/td-setup-mac-${_install_version}.dmg"
			else
				echo "https://github.com/telegramdesktop/tdesktop/releases/download/v${_install_version}/tsetup.${_install_version}.dmg"
			fi ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${_install_version}/uv-x86_64-apple-darwin.tar.gz" ;;
		vscode)
			echo "https://update.code.visualstudio.com/${_install_version}/darwin/stable" ;;
		waterfox)
			echo "https://cdn.waterfox.com/waterfox/releases/${_install_version}/Darwin_x86_64-aarch64/Waterfox%20${_install_version}.dmg" ;;
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
		firefox)
			echo "https://ftp.mozilla.org/pub/firefox/releases/${_install_version}/mac/en-US/Firefox%20${_install_version}.dmg" ;;
		foundry)
			echo "https://github.com/foundry-rs/foundry/releases/download/v${_install_version}/foundry_v${_install_version}_darwin_arm64.tar.gz" ;;
		go)
			if is_version_at_least "${_install_version}" "1.16beta1"; then
				echo "https://go.dev/dl/go${_install_version}.darwin-arm64.tar.gz"
			else
				echo ""
			fi ;;
		hugo)
			echo "https://github.com/gohugoio/hugo/releases/download/v${_install_version}/hugo_extended_withdeploy_${_install_version}_darwin-universal.pkg" ;;
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
		telegram)
			if is_version_at_least "${_install_version}" "7.2.6"; then
				echo "https://github.com/telegramdesktop/tdesktop/releases/download/v${_install_version}/td-setup-mac-${_install_version}.dmg"
			else
				echo "https://github.com/telegramdesktop/tdesktop/releases/download/v${_install_version}/tsetup.${_install_version}.dmg"
			fi ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${_install_version}/uv-aarch64-apple-darwin.tar.gz" ;;
		vscode)
			echo "https://update.code.visualstudio.com/${_install_version}/darwin-arm64/stable" ;;
		waterfox)
			echo "https://cdn.waterfox.com/waterfox/releases/${_install_version}/Darwin_x86_64-aarch64/Waterfox%20${_install_version}.dmg" ;;
		*) echo "" ;;
	esac
}
