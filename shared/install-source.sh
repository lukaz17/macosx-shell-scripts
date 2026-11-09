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
	case "$1" in
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
	case "$1" in
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
	case "$1" in
		localai)
			echo "" ;;
		opencode)
			echo "https://github.com/anomalyco/opencode/releases/download/v${2}/opencode-darwin-x64.zip" ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${2}/uv-x86_64-apple-darwin.tar.gz" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the download URI for ARM64 for a Program ID.
# ------------------------------------------------------------------------------
get_download_uri_arm64() {
	case "$1" in
		localai)
			echo "https://github.com/mudler/LocalAI/releases/download/v${2}/local-ai-v${2}-darwin-arm64" ;;
		opencode)
			echo "https://github.com/anomalyco/opencode/releases/download/v${2}/opencode-darwin-arm64.zip" ;;
		uv)
			echo "https://github.com/astral-sh/uv/releases/download/${2}/uv-aarch64-apple-darwin.tar.gz" ;;
		*) echo "" ;;
	esac
}
