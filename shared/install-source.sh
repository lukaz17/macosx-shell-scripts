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
		opencode) echo "anomalyco" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the GitHub repository for a Program ID.
# ------------------------------------------------------------------------------
get_source_repo() {
	case "$1" in
		opencode) echo "opencode" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the download URI for AMD64 for a Program ID.
# ------------------------------------------------------------------------------
get_download_uri_amd64() {
	case "$1" in
		opencode)
			echo "https://github.com/anomalyco/opencode/releases/download/v${2}/opencode-darwin-x64.zip" ;;
		*) echo "" ;;
	esac
}

# ------------------------------------------------------------------------------
# Return the download URI for ARM64 for a Program ID.
# ------------------------------------------------------------------------------
get_download_uri_arm64() {
	case "$1" in
		opencode)
			echo "https://github.com/anomalyco/opencode/releases/download/v${2}/opencode-darwin-arm64.zip" ;;
		*) echo "" ;;
	esac
}
