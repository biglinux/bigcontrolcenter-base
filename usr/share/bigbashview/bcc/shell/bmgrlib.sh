#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  bmgrlib.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2023/08/11
#  Altered: 2023/08/20
#
#  Copyright (c) 2023-2023, Vilmar Catafesta <vcatafesta@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

APP="${0##*/}"
_VERSION_="1.0.0-20230819"
export BOOTLOG="/tmp/big-driver-manager-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-driver-manager
unset GREP_OPTIONS

function sh_driver_mhwd {
	[[ -e $HOME/.config/bigcontrolcenter-drivers/cache_video_*.html ]] && rm -f $HOME/.config/bigcontrolcenter-drivers/cache_video_*.html

	SHOW_DRIVER() {
		# $CATEGORY
		# $VIDEO_DRIVER_NAME
		# $VIDEO_DRIVER_ENABLED
		# $VIDEO_DRIVER_COMPATIBLE
		# $VIDEO_DRIVER_OPEN

		OPEN_OR_PROPRIETARY=$([[ "$VIDEO_DRIVER_OPEN" = "true" ]] && echo $"Este driver é software livre." || echo $"Este driver é proprietário.")
		DRIVER_COMPATIBLE=$([[ "$VIDEO_DRIVER_COMPATIBLE" = "true" ]] && echo $"Este driver parece compatível com este computador.")

		if [[ "$VIDEO_DRIVER_ENABLED" = "true" ]]; then
			DRIVER_ENABLE_OR_DISABLE=$"Remover"
			INSTALL_OR_REMOVE_VIDEO="remove_video_now"
			DISABLED_BUTTON="remove-button"
			DISABLED_MESSAGE=""
		else
			DRIVER_ENABLE_OR_DISABLE=$"Instalar"
			INSTALL_OR_REMOVE_VIDEO="install_video_now"
			#			if [ "$VIDEO_DRIVER_NVIDIA_ENABLED" = "true" ] && [ "$(echo "$VIDEO_DRIVER_NAME" | grep nvidia)" != "" ]; then
			if [[ "$VIDEO_DRIVER_NVIDIA_ENABLED" = "true" && "$VIDEO_DRIVER_NAME" =~ nvidia ]]; then
				DISABLED_BUTTON="disabled"
				DRIVER_ENABLE_OR_DISABLE=$"Desativado"
				DISABLED_MESSAGE=$"Antes de instalar este driver, remova o outro driver Nvidia."
				#DRIVER_ENABLE_OR_DISABLE=$"Já existe outro driver nVidia instalado, para instalar este driver, remova primeiro o driver instalado."
			else
				INSTALL_OR_REMOVE_VIDEO="install_video_now"
				DISABLED_BUTTON=""
				DISABLED_MESSAGE=""
			fi
		fi

		#		VIDEO_DRIVER_NAME_CLEAN="$(echo "$VIDEO_DRIVER_NAME" | sed 's|-| |g')"
		VIDEO_DRIVER_NAME_CLEAN=${VIDEO_DRIVER_NAME//-/ }

		#		if [[ "$VIDEO_DRIVER_NAME_CLEAN" = "video nvidia" ]]; then
		#			VIDEO_DRIVER_NAME_CLEAN="video nvidia $(LC_ALL=C pacman -Si nvidia-utils | grep "^Version" | cut -f2 -d":" | sed 's|\..*|xx|g')"
		#		fi

		if [[ "$VIDEO_DRIVER_NAME_CLEAN" = "video nvidia" ]]; then
			nvidia_version=$(LC_ALL=C pacman -Si nvidia-utils | awk '/^Version/ {print $2}' | cut -d. -f1)
			VIDEO_DRIVER_NAME_CLEAN="video nvidia ${nvidia_version}xx"
		fi

		cat <<-EOF >>"$HOME/.config/bigcontrolcenter-drivers/cache_video_$VIDEO_DRIVER_NAME.html"
			<div class="app-card $CATEGORY">
			<span class="icon-cat icon-category-$CATEGORY" style="display:table-cell;">
			</span>
			<span class="titlespan" style="display:table-cell;">
			$VIDEO_DRIVER_NAME_CLEAN
			</span>
			<div class="app-card__subtext">
			$OPEN_OR_PROPRIETARY
			<br>
			<br>
			$DESC
			$DISABLED_MESSAGE
			</div>
		EOF

		cat <<-EOF >>"$HOME/.config/bigcontrolcenter-drivers/cache_video_$VIDEO_DRIVER_NAME.html"
			<div class="app-card-buttons">
			<a class="content-button status-button  $DISABLED_BUTTON" $DISABLED_BUTTON" onclick="disableBodyConfig();" href="index.sh.htm?${INSTALL_OR_REMOVE_VIDEO}=${VIDEO_DRIVER_NAME}">
			$DRIVER_ENABLE_OR_DISABLE
			</a>
			</div>
			</div>
		EOF
	}

	# MHWD import info OPEN, used to video drivers
	##############################################

	# If module is proprietary show false
	# Result example: video-nvidia-470xx false
	#	VIDEO_DRIVER_SHOW_ALL_AND_IF_IS_FREE="$(mhwd -la | awk '{ print $1 " " $3 }' | grep -e 'video-' -e 'network-')"
	VIDEO_DRIVER_SHOW_ALL_AND_IF_IS_FREE="$(mhwd -la | awk '/video-|network-/ { print $1, $3 }')"

	# Show compatible with this hardware
	#	VIDEO_DRIVER_COMPATIBLE_WITH_THIS_HARDWARE="$(mhwd -l | awk '{ print $1 }' | grep -e video- -e network-) | tee"
	VIDEO_DRIVER_COMPATIBLE_WITH_THIS_HARDWARE="$(mhwd -l | awk '/video-|network-/ { print $1 }')"

	# Show if installed
	#	VIDEO_DRIVER_ENABLED_LIST="$(mhwd -li | awk '{ print $1 }' | grep -e video- -e network-) | tee"
	VIDEO_DRIVER_ENABLED_LIST="$(mhwd -li | awk '/video-|network-/ { print $1 }')"

	# Show if nvidia driver is enabled
	#	if [ "$(echo "$VIDEO_DRIVER_ENABLED_LIST" | grep -i nvidia)" != "" ]; then
	if [[ $VIDEO_DRIVER_ENABLED_LIST =~ "nvidia" ]]; then
		VIDEO_DRIVER_NVIDIA_ENABLED="true"
	fi

	for i in $VIDEO_DRIVER_SHOW_ALL_AND_IF_IS_FREE; do
		#		VIDEO_DRIVER_NAME="$(echo "$i" | cut -f1 -d" ")"
		#		VIDEO_DRIVER_OPEN="$(echo "$i" | cut -f2 -d" ")"
		read -r VIDEO_DRIVER_NAME _ <<<"$i"
		read -r _ VIDEO_DRIVER_OPEN <<<"$i"

		#		if [ "$(echo "$VIDEO_DRIVER_ENABLED_LIST" | grep "^$VIDEO_DRIVER_NAME$")" != "" ]; then
		#		if [[ $VIDEO_DRIVER_ENABLED_LIST =~ (^|[[:space:]])$VIDEO_DRIVER_NAME($|[[:space:]]) ]]; then
		if [[ " $VIDEO_DRIVER_ENABLED_LIST " == *" $VIDEO_DRIVER_NAME "* ]]; then
			VIDEO_DRIVER_ENABLED="true"
		else
			VIDEO_DRIVER_ENABLED="false"
		fi

		#		if [ "$(echo "$VIDEO_DRIVER_COMPATIBLE_WITH_THIS_HARDWARE" | grep -ve video-linux -ve video-modesetting -ve video-vesa | grep "^$VIDEO_DRIVER_NAME$")" != "" ]; then
		if echo "$VIDEO_DRIVER_COMPATIBLE_WITH_THIS_HARDWARE" | grep -E -v 'video-(linux|modesetting|vesa)' | grep -q "^$VIDEO_DRIVER_NAME$"; then
			VIDEO_DRIVER_COMPATIBLE="true"
			#			if [ "$(echo "$VIDEO_DRIVER_NAME" | grep network)" != "" ]; then
			if [[ $VIDEO_DRIVER_NAME == *network* ]]; then
				CATEGORY="wifi Star"
				#				if [ "$(echo "$VIDEO_DRIVER_NAME" | grep 8168)" != "" ]; then
				if [[ $VIDEO_DRIVER_NAME == *8168* ]]; then
					CATEGORY="ethernet Star"
				fi
			else
				CATEGORY="Gpu Star"
			fi
		else
			VIDEO_DRIVER_COMPATIBLE="false"
			#			if [ "$(echo "$VIDEO_DRIVER_NAME" | grep network)" != "" ]; then
			if [[ $VIDEO_DRIVER_NAME == *network* ]]; then
				CATEGORY="wifi"
				#				if [ "$(echo "$VIDEO_DRIVER_NAME" | grep 8168)" != "" ]; then
				if [[ $VIDEO_DRIVER_NAME == *8168* ]]; then
					CATEGORY="ethernet"
				fi
			else
				CATEGORY="Gpu"
			fi
		fi
		SHOW_DRIVER "$VIDEO_DRIVER_NAME" "$VIDEO_DRIVER_ENABLED" "$VIDEO_DRIVER_COMPATIBLE" "$VIDEO_DRIVER_OPEN"
	done
	IFS=$OIFS
}
export -f sh_driver_mhwd

function sh_driver_without_verify {
	local device="$1"

	OIFS=$IFS
	IFS=$'\n'

	SHOW_INSTALLED_PKG() {
		local category=$1
		local pkg=$2
		local desc=$3

		PKG_INSTALLED_OR_NOT=$"Remover"
		cat <<-EOF >>"$HOME/.config/bigcontrolcenter-drivers/cache_without_verify_installed_$device_$pkg.html"
			<div class="app-card $category">
			<span class="icon-cat icon-category-$category" style="display:table-cell;">
			</span>
			<span class="titlespan" style="display:table-cell;">
			$pkg
			</span>
			<div class="app-card__subtext">
			$desc
			</div>
			<div class="app-card-buttons">
			<a class="content-button status-button remove-button" onclick="disableBodyConfigSimple();" href="index.sh.htm?remove_pkg_pamac=${pkg}">
			$PKG_INSTALLED_OR_NOT
			</a>
			</div>
			</div>
		EOF
	}

	SHOW_NOT_INSTALLED_PKG() {
		local category=$1
		local pkg=$2
		local desc=$3

		PKG_INSTALLED_OR_NOT=$"Instalar"
		cat <<-EOF >>"$HOME/.config/bigcontrolcenter-drivers/cache_without_verify_not_installed_$category_$pkg.html"
			<div class="app-card $category">
			<span class="icon-cat icon-category-$category" style="display:table-cell;">
			</span><span class="titlespan" style="display:table-cell;">
			$pkg
			</span>
			<div class="app-card__subtext">
			$desc
			</div>
			<div class="app-card-buttons">
			<a class="content-button status-button" onclick="disableBodyConfigSimple();" href="index.sh.htm?install_pkg_pamac=${pkg}">
			$PKG_INSTALLED_OR_NOT
			</a>
			</div>
			</div>
		EOF
	}

	# See PKGS to verify
	#	ls -w1 -d $device/*/ | cut -f2 -d/ >"$HOME/.config/bigcontrolcenter-drivers/list_cache_without_verify_$device.html"
	#	INSTALLED_PKGS="$(grep -xFf "$HOME/.config/bigcontrolcenter-drivers/total_pkgs" "$HOME/.config/bigcontrolcenter-drivers/list_cache_without_verify_$device.html")"

	cache_file="$HOME/.config/bigcontrolcenter-drivers/list_cache_without_verify_$device.html"
	pkg_list_file="$HOME/.config/bigcontrolcenter-drivers/total_pkgs"
	ls -w1 -d "$device"/*/ | cut -f2 -d/ >"$cache_file"
	INSTALLED_PKGS=$(grep -xFf "$pkg_list_file" "$cache_file")

	for PKG in $INSTALLED_PKGS; do
		CATEGORY="$device"
		#		DESC="$(cat $device/$PKG/description)"
		DESC="$(<"$device/$PKG/description")"
		SHOW_INSTALLED_PKG "$device" "$PKG" "$CATEGORY" "$DESC" &
	done

	NOT_INSTALLED_PKGS="$(grep -vxFf "$HOME/.config/bigcontrolcenter-drivers/total_pkgs" "$HOME/.config/bigcontrolcenter-drivers/list_cache_without_verify_$device.html")"
	for PKG in $NOT_INSTALLED_PKGS; do
		CATEGORY="$device"
		#		DESC="$(cat $device/$PKG/description)"
		DESC="$(<"$device/$PKG/description")"
		SHOW_NOT_INSTALLED_PKG "$device" "$PKG" "$CATEGORY" "$DESC" &
	done
	IFS=$OIFS
}
export -f sh_driver_without_verify

function sh_main {
	local execute_app="$1"

	if test $# -ge 1; then
		shift
		eval "$execute_app"
	fi
	#	return
}

#sh_debug
sh_main "$@"
