#!/bin/sh

################################################################################
#
#  install-common
#  Libraries to support *-install scripts
#
#  MIT License.
#  Copyright (C) 2025 Nguyen Nhat Tung.
#
################################################################################

# ------------------------------------------------------------------------------
# Create a directory safely.
# ------------------------------------------------------------------------------
create_dir() {
	_path="${1}"
	if [ -z "${_path}" ]; then
		echo "create_dir: Invalid arguments" >&2
		return 1
	fi

	if [ ! -d "${_path}" ]; then
		echo "> Create Dir:   ${_path}"
		mkdir -p "${_path}"
	fi
}

# ------------------------------------------------------------------------------
# Create a directory safely, owned by the invoking user when run with sudo.
# ------------------------------------------------------------------------------
create_user_dir() {
	_path="${1}"
	if [ -z "${_path}" ]; then
		echo "create_user_dir: Invalid arguments" >&2
		return 1
	fi

	if [ ! -d "${_path}" ]; then
		echo "> Create Dir:   ${_path}"
		if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER}" ]; then
			sudo -u "${SUDO_USER}" mkdir -p "${_path}"
		else
			mkdir -p "${_path}"
		fi
	fi
}

# ------------------------------------------------------------------------------
# Remove file/folder safely.
# ------------------------------------------------------------------------------
remove_item() {
	_path="${1}"
	if [ -z "${_path}" ]; then
		echo "remove_item: Invalid arguments" >&2
		return 1
	fi

	if [ -f "${_path}" ] || [ -d "${_path}" ] || [ -L "${_path}" ]; then
		echo "> Remove Item:  ${_path}"
		rm -r "${_path}"
	fi
}

# ------------------------------------------------------------------------------
# Copy file/folder safely.
# ------------------------------------------------------------------------------
copy_item() {
	_from="${1}"
	_to="${2}"
	if [ -z "${_from}" ] || [ -z "${_to}" ]; then
		echo "copy_item: Invalid arguments" >&2
		return 1
	fi

	echo "> Copy Item:    ${_from} -> ${_to}"
	cp -r -P "${_from}" "${_to}"
}

# ------------------------------------------------------------------------------
# Copy file/folder and overwrite the target.
# ------------------------------------------------------------------------------
copy_item_overwrite() {
	_from="${1}"
	_to="${2}"
	if [ -z "${_from}" ] || [ -z "${_to}" ]; then
		echo "copy_item_overwrite: Invalid arguments" >&2
		return 1
	fi

	remove_item "${_to}"
	echo "> Copy Item:    ${_from} -> ${_to}"
	cp -r -P "${_from}" "${_to}"
}

# ------------------------------------------------------------------------------
# Move file/folder safely.
# ------------------------------------------------------------------------------
move_item() {
	_from="${1}"
	_to="${2}"
	if [ -z "${_from}" ] || [ -z "${_to}" ]; then
		echo "move_item: Invalid arguments" >&2
		return 1
	fi

	echo "> Move Item:    ${_from} -> ${_to}"
	mv "${_from}" "${_to}"
}

# ------------------------------------------------------------------------------
# Move file/folder and overwrite the target.
# ------------------------------------------------------------------------------
move_item_overwrite() {
	_from="${1}"
	_to="${2}"
	if [ -z "${_from}" ] || [ -z "${_to}" ]; then
		echo "move_item_overwrite: Invalid arguments" >&2
		return 1
	fi

	remove_item "${_to}"
	echo "> Move Item:    ${_from} -> ${_to}"
	mv "${_from}" "${_to}"
}

# ------------------------------------------------------------------------------
# Symlink file/folder safely.
# ------------------------------------------------------------------------------
symlink_item() {
	_from="${1}"
	_to="${2}"
	if [ -z "${_from}" ] || [ -z "${_to}" ]; then
		echo "symlink_item: Invalid arguments" >&2
		return 1
	fi

	echo "> Link Item:    ${_from} -> ${_to}"
	ln -s "${_from}" "${_to}"
}

# ------------------------------------------------------------------------------
# Symlink file/folder and overwrite the target, failing if the file/folder is missing.
# ------------------------------------------------------------------------------
symlink_item_overwrite() {
	_from="${1}"
	_to="${2}"
	if [ -z "${_from}" ] || [ -z "${_to}" ]; then
		echo "symlink_item_overwrite: Invalid arguments" >&2
		return 1
	fi
	if [ ! -e "${_from}" ]; then
		echo "symlink_item_overwrite: Item not found: ${_from}" >&2
		return 1
	fi

	remove_item "${_to}"
	echo "> Link Item:    ${_from} -> ${_to}"
	ln -s "${_from}" "${_to}"
}

# ------------------------------------------------------------------------------
# Make a file/folder executable.
# ------------------------------------------------------------------------------
make_executable() {
	_path="${1}"
	if [ -z "${_path}" ]; then
		echo "make_executable: Invalid arguments" >&2
		return 1
	fi

	if [ -f "${_path}" ] || [ -d "${_path}" ]; then
		echo "> Make Exec:    ${_path}"
		chmod +x "${_path}"
	fi
}

# ------------------------------------------------------------------------------
# Parse arguments for the install scripts.
# ------------------------------------------------------------------------------
get_install_argument() {
	INSTALL_ARG_VERSION=""
	INSTALL_ARG_IS_DEFAULT=0
	for _argument in "$@"; do
		if [ "${_argument}" = "--default" ]; then
			INSTALL_ARG_IS_DEFAULT=1
		elif [ -z "${INSTALL_ARG_VERSION}" ]; then
			INSTALL_ARG_VERSION="${_argument}"
		else
			echo "get_install_argument: Expected [<version>] [--default], got: $*" >&2
			return 1
		fi
	done
}

# ------------------------------------------------------------------------------
# Normalize install version for consistency.
# ------------------------------------------------------------------------------
normalize_install_version() {
	_fallback_version="${1}"
	if [ -z "${INSTALL_VERSION}" ]; then
		if [ -n "${_fallback_version}" ]; then
			INSTALL_VERSION="${_fallback_version}"
		else
			echo "normalize_install_version: Install version is not specified" >&2
			return 1
		fi
	fi

	INSTALL_VERSION="${INSTALL_VERSION#v}"
}

# ------------------------------------------------------------------------------
# Extract the major version from a version string.
# ------------------------------------------------------------------------------
get_version_major() {
	_version="${1}"
	if [ -z "${_version}" ]; then
		echo "get_version_major: Invalid arguments" >&2
		return 1
	fi

	_version_core="${_version#v}"
	_version_core="${_version_core%%-*}"
	_major="${_version_core%%.*}"
	case "${_major}" in
		'' | *[!0-9]*)
			echo "get_version_major: Invalid version: ${_version}" >&2
			return 1
			;;
	esac
	echo "${_major}"
}

# ------------------------------------------------------------------------------
# Compare two versions, print -1, 0 or 1 when the first is older, equal or newer:
# - Missing release parts count as 0: 2 = 2.0 = 2.0.0.
# - A pre-release is older than its release: 2.0.0-beta.1 < 2.0.0, 1.27rc1 < 1.27.0.
# - Pre-releases compare digit runs as numbers: beta.2 < beta.10, rc9 < rc10.
# ------------------------------------------------------------------------------
compare_version() {
	_version_left="${1}"
	_version_right="${2}"
	if [ -z "${_version_left}" ] || [ -z "${_version_right}" ]; then
		echo "compare_version: Invalid arguments" >&2
		return 1
	fi

	# macOS sort -V orders 2 < 2.0.0 and 2.0.0 < 2.0.0-beta.1, so compare explicitly
	awk -v left="${_version_left}" -v right="${_version_right}" '
		function order(x, y) {
			return (x < y) ? -1 : ((x > y) ? 1 : 0)
		}
		function split_version(version, parts) {
			sub(/^v/, "", version)
			match(version, /^[0-9.]*/)
			parts["release"] = substr(version, 1, RLENGTH)
			parts["pre"] = substr(version, RLENGTH + 1)
			sub(/^[-.]/, "", parts["pre"])
		}
		function order_release(x, y,    xs, ys, xn, yn, i, result) {
			xn = split(x, xs, ".")
			yn = split(y, ys, ".")
			for (i = 1; i <= xn || i <= yn; i++) {
				result = order(xs[i] + 0, ys[i] + 0)
				if (result != 0) return result
			}
			return 0
		}
		function order_pre(x, y,    xt, yt, result) {
			while (x != "" && y != "") {
				match(x, /^([0-9]+|[^0-9]+)/)
				xt = substr(x, 1, RLENGTH)
				x = substr(x, RLENGTH + 1)
				match(y, /^([0-9]+|[^0-9]+)/)
				yt = substr(y, 1, RLENGTH)
				y = substr(y, RLENGTH + 1)
				if (xt ~ /^[0-9]/ && yt ~ /^[0-9]/) {
					result = order(xt + 0, yt + 0)
				} else {
					result = order(xt "", yt "")
				}
				if (result != 0) return result
			}
			return order(x != "", y != "")
		}
		BEGIN {
			split_version(left, lv)
			split_version(right, rv)
			result = order_release(lv["release"], rv["release"])
			if (result == 0 && (lv["pre"] == "" || rv["pre"] == "")) {
				result = order(lv["pre"] == "", rv["pre"] == "")
			} else if (result == 0) {
				result = order_pre(lv["pre"], rv["pre"])
			}
			print result
		}
	'
}

# ------------------------------------------------------------------------------
# Check that the first version is not older than the second.
# ------------------------------------------------------------------------------
is_version_at_least() {
	_version_to_check="${1}"
	_version_anchor="${2}"
	_version_order="$(compare_version "${_version_to_check}" "${_version_anchor}")" || return 1
	[ "${_version_order}" -ge 0 ]
}

# ------------------------------------------------------------------------------
# Check that the first version is not newer than the second.
# ------------------------------------------------------------------------------
is_version_at_most() {
	_version_to_check="${1}"
	_version_anchor="${2}"
	_version_order="$(compare_version "${_version_to_check}" "${_version_anchor}")" || return 1
	[ "${_version_order}" -le 0 ]
}

# ------------------------------------------------------------------------------
# Get latest version from GitHub.
# ------------------------------------------------------------------------------
get_install_version_from_github() {
	_github_owner="${1}"
	_github_repository="${2}"
	_fallback_version="${3}"
	_trim_prefix="${4}"
	_tag_filter="${5}"
	if [ -z "${_github_owner}" ] || [ -z "${_github_repository}" ]; then
		echo "get_install_version_from_github: Invalid arguments" >&2
		return 1
	fi

	if [ -z "${_fallback_version}" ]; then
		if [ -n "${_tag_filter}" ]; then
			INSTALL_VERSION="$(curl -fsSL "https://api.github.com/repos/${_github_owner}/${_github_repository}/releases?per_page=50" | jq -r "[.[] | select(.tag_name | startswith(\"${_tag_filter}\"))] | first | .tag_name")"
		else
			INSTALL_VERSION="$(curl -fsSL "https://api.github.com/repos/${_github_owner}/${_github_repository}/releases/latest" | jq -r .tag_name)"
		fi
		if [ -n "${_trim_prefix}" ]; then
			INSTALL_VERSION="${INSTALL_VERSION#${_trim_prefix}}"
		fi
	else
		INSTALL_VERSION="${_fallback_version}"
	fi
	normalize_install_version
	echo "> Latest Version:  ${INSTALL_VERSION}"
}

# ------------------------------------------------------------------------------
# Initialize environment for the install and pre-populate root dirs.
# ------------------------------------------------------------------------------
init_install_env() {
	_program_id="${1}"
	_install_version="${2}"
	_active_tag="${3}"
	if [ -z "${_program_id}" ] || [ -z "${_install_version}" ]; then
		echo "init_install_env: Invalid arguments" >&2
		return 1
	fi

	echo "> Init InstEnv: ${_program_id} v${_install_version} $(uname -m)"

	_user_id="$(id -u)"
	if [ "${_user_id}" -eq 0 ]; then
		INSTALL_ROOT="/usr/local/share/${_program_id}"
		SYSTEM_BIN_ROOT="/usr/local/bin"
	else
		INSTALL_ROOT="${HOME}/.local/share/${_program_id}"
		SYSTEM_BIN_ROOT="${HOME}/.local/bin"
	fi
	TEMP_ROOT="/tmp"
	USER_PROFILE_RC="${HOME}/.zprofile"
	USER_BASH_RC="${HOME}/.zshrc"
	USER_PROFILE_DATA="${HOME}/.local"

	if [ -n "${CLIINST_USR_LOCAL_SHARE}" ]; then
		INSTALL_ROOT="${CLIINST_USR_LOCAL_SHARE}/${_program_id}"
	fi
	if [ -n "${CLIINST_USR_PROFILE}" ]; then
		USER_PROFILE_DATA="${CLIINST_USR_PROFILE}"
	fi
	if [ -n "${CLIINST_TMP}" ]; then
		TEMP_ROOT="${CLIINST_TMP}"
	fi

	INSTALL_TARGET="${INSTALL_ROOT}/${_program_id}-v${_install_version}"
	DEFAULT_TARGET="${INSTALL_ROOT}/active-release"
	ACTIVE_TARGET="${DEFAULT_TARGET}${_active_tag:+-${_active_tag}}"
	TEMP_TARGET="${TEMP_ROOT}/${_program_id}-v${_install_version}"

	create_dir "${INSTALL_ROOT}"
	create_dir "${SYSTEM_BIN_ROOT}"
	create_user_dir "${USER_PROFILE_DATA}"
}

# ------------------------------------------------------------------------------
# Extended version of init_install_env to support desktop environment.
# ------------------------------------------------------------------------------
init_install_env_desktop() {
	_program_id="${1}"
	_install_version="${2}"
	init_install_env "${_program_id}" "${_install_version}" || return 1

	_user_id="$(id -u)"
	if [ "${_user_id}" -eq 0 ]; then
		DESKTOP_ROOT="/Applications"
	else
		DESKTOP_ROOT="${HOME}/Desktop"
	fi
}

# ------------------------------------------------------------------------------
# Download different file based on current system architecture.
# ------------------------------------------------------------------------------
download_uri_per_arch() {
	_amd64_url="${1}"
	_arm64_url="${2}"
	_destination="${3}"
	if [ -z "${_amd64_url}" ] && [ -z "${_arm64_url}" ]; then
		echo "download_uri_per_arch: Invalid arguments" >&2
		return 1
	fi
	if [ -z "${_destination}" ]; then
		echo "download_uri_per_arch: Invalid arguments" >&2
		return 1
	fi

	_arch="$(uname -m)"
	if [ "${_arch}" = "x86_64" ] || [ "${_arch}" = "amd64" ]; then
		if [ -z "${_amd64_url}" ]; then
			echo "download_uri_per_arch: Unsupported architecture: ${_arch}" >&2
			exit 1
		fi
		echo "> Download Uri: ${_amd64_url} -> ${_destination}"
		curl -fSL "${_amd64_url}" -o "${_destination}"
	elif [ "${_arch}" = "aarch64" ] || [ "${_arch}" = "arm64" ]; then
		if [ -z "${_arm64_url}" ]; then
			echo "download_uri_per_arch: Unsupported architecture: ${_arch}" >&2
			exit 1
		fi
		echo "> Download Uri: ${_arm64_url} -> ${_destination}"
		curl -fSL "${_arm64_url}" -o "${_destination}"
	else
		echo "download_uri_per_arch: Unsupported architecture: ${_arch}" >&2
		exit 1
	fi
}

# ------------------------------------------------------------------------------
# Move file/folder based on current system architecture.
# ------------------------------------------------------------------------------
move_item_per_arch() {
	_amd64_path="${1}"
	_arm64_path="${2}"
	_destination="${3}"
	if [ -z "${_amd64_path}" ] && [ -z "${_arm64_path}" ]; then
		echo "move_item_per_arch: Invalid arguments" >&2
		return 1
	fi
	if [ -z "${_destination}" ]; then
		echo "move_item_per_arch: Invalid arguments" >&2
		return 1
	fi

	_arch="$(uname -m)"
	if [ "${_arch}" = "x86_64" ] || [ "${_arch}" = "amd64" ]; then
		if [ -z "${_amd64_path}" ]; then
			echo "move_item_per_arch: Unsupported architecture: ${_arch}" >&2
			exit 1
		fi
		move_item "${_amd64_path}" "${_destination}"
	elif [ "${_arch}" = "aarch64" ] || [ "${_arch}" = "arm64" ]; then
		if [ -z "${_arm64_path}" ]; then
			echo "move_item_per_arch: Unsupported architecture: ${_arch}" >&2
			exit 1
		fi
		move_item "${_arm64_path}" "${_destination}"
	else
		echo "move_item_per_arch: Unsupported architecture: ${_arch}" >&2
		exit 1
	fi
}

# ------------------------------------------------------------------------------
# Extract archive.
# ------------------------------------------------------------------------------
extract_archive() {
	_archive_file="${1}"
	_archive_type="${2}"
	_destination_dir="${3}"
	if [ -z "${_archive_file}" ] || [ -z "${_archive_type}" ] || [ -z "${_destination_dir}" ]; then
		echo "extract_archive: Invalid arguments" >&2
		return 1
	fi

	echo "> Extract Arch: ${_archive_file} -> ${_destination_dir}"
	if [ "${_archive_type}" = "dmg" ] || [ "${_archive_type}" = "DMG" ]; then
		_mount_point="/Volumes/CLI Auto Install"
		echo "> Mount Dmg:    ${_archive_file}"
		hdiutil attach -mountpoint "${_mount_point}" "${_archive_file}"
		for _app_file in "${_mount_point}"/*.app; do
			copy_item "${_app_file}" "${_destination_dir}"
		done
		hdiutil detach "${_mount_point}"
		echo "> Unmount Dmg:  ${_archive_file}"
		xattr -cr "${_destination_dir}"
	elif [ "${_archive_type}" = "pkg" ] || [ "${_archive_type}" = "PKG" ]; then
		remove_item "${_destination_dir}"
		pkgutil --expand-full "${_archive_file}" "${_destination_dir}"
	elif [ "${_archive_type}" = "tar" ] || [ "${_archive_type}" = "TAR" ]; then
		tar -x -v -f "${_archive_file}" -C "${_destination_dir}"
	elif [ "${_archive_type}" = "zip" ] || [ "${_archive_type}" = "ZIP" ]; then
		unzip "${_archive_file}" -d "${_destination_dir}"
	else
		echo "extract_archive: Unsupported archive type: ${_archive_type}" >&2
		exit 1
	fi
}

# ------------------------------------------------------------------------------
# Append text into a file:
# - If the text matches a whole-line in the file, do nothing.
# - The text must be inserted as a whole-line.
# - The text can have an optional newline: real newline or a literal "\n" to create 1-line spacing from existing content.
# - The optional newline can only be placed at the beginning of the text, otherwise throw an error.
# - The file must end with a newline.
# ------------------------------------------------------------------------------
append_text_idempotent() {
	_text="${1}"
	_file="${2}"
	if [ -z "${_text}" ] || [ -z "${_file}" ]; then
		echo "append_text_idempotent: Invalid arguments" >&2
		return 1
	fi
	# Optional newline: a real newline or a literal "\n".
	# Only the content after the newline is used for the idempotent check.
	# The newline itself adds a blank line separator before the content.
	_has_newline=0
	case "${_text}" in
		'
'*)
			_content="${_text#?}"
			_has_newline=1
			;;
		'\n'*)
			_content="${_text#??}"
			_has_newline=1
			;;
		*)
			_content="${_text}"
			;;
	esac
	case "${_content}" in
		*'
'* | *'\n'*)
			echo "append_text_idempotent: Invalid arguments" >&2
			return 1
			;;
	esac
	if [ -z "${_content}" ]; then
		echo "append_text_idempotent: Invalid arguments" >&2
		return 1
	fi

	# Whole-line match on the content: nothing to do.
	if grep -qFxe "${_content}" "${_file}" 2>/dev/null; then
		return 0
	fi

	if [ -s "${_file}" ]; then
		# Ensure the file ends with a newline before appending.
		_last_char="$(tail -c 1 "${_file}" 2>/dev/null)"
		if [ -n "${_last_char}" ]; then
			printf '\n' >> "${_file}"
		fi
		# Insert the content
		if [ "${_has_newline}" -eq 1 ]; then
			printf '\n%s\n' "${_content}" >> "${_file}"
		else
			printf '%s\n' "${_content}" >> "${_file}"
		fi
	else
		# Create new file with the content
		printf '%s\n' "${_content}" >> "${_file}"
	fi
	echo "> Updated Cfg:  ${_file}"
}

# ------------------------------------------------------------------------------
# Finalize install.
# ------------------------------------------------------------------------------
finalize_install() {
	echo "> Success."
}
