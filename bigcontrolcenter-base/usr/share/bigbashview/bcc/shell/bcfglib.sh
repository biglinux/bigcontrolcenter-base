#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  bccfglib.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2023/08/04
#  Altered: 2024/07/16
#
#  Copyright (c) 2023-2024, Vilmar Catafesta <vcatafesta@gmail.com>
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

[[ -n "$LIB_BCFGLIB_SH" ]] && return
LIB_BCFGLIB_SH=1
shopt -s extglob

APP="${0##*/}"
_DATE_ALTERED_="16-07-2024 - 13:36"
_VERSION_="1.0.0-20240716"
_BCFGLIB_VERSION_="${_VERSION_} - ${_DATE_ALTERED_}"
_UPDATED_="${_DATE_ALTERED_}"

#######################################################################################################################

# determina se o fundo do KDE está em modo claro ou escuro
function sh_bcfg_getbgcolor() {
    local result
    local r g b
    local average_rgb

    if lightmode="$(TIni.Get "$INI_FILE_BIG_CONFIG" 'config' 'lightmode')" && [[ -z "$lightmode" ]]; then
        # Read background color RGB values
        lightmode=0
        if result="$(kreadconfig5 --group "Colors:Window" --key BackgroundNormal)" && [[ -n "$result" ]]; then
            r=${result%,*}
            g=${result#*,}
            g=${g%,*}
            b=${result##*,}
            average_rgb=$(((r + g + b) / 3))
            if ((average_rgb > 127)); then
                lightmode=1
            fi
        fi
        TIni.Set "$INI_FILE_BIG_CONFIG" 'config' 'lightmode' "$lightmode"
    fi

    if ((lightmode)); then
        echo '<body class=light-mode>'
    else
        echo '<body>'
    fi
}
export -f sh_bcfg_getbgcolor

#######################################################################################################################

function sh_bcfg_setbgcolor() {
    local param="$1"
    local lightmode=1

    [[ "$param" = "true" ]] && lightmode=0
    TIni.Set "$INI_FILE_BIG_CONFIG" 'config' 'lightmode' "$lightmode"
}
export -f sh_bcfg_setbgcolor

#######################################################################################################################

function sh_reset_brave {
	local result

	# Verifica se o processo está em execução (usando pidof) e se há um resultado não vazio.
	if result=$(pidof brave) && [[ -n $result ]]; then
		# Se estiver em execução, imprime o ID do processo e encerra o script.
		echo -n "$result"
		return
	fi
	 rm -r ~/.config/BraveSoftware
	echo -n "#"
	return
}
export -f sh_reset_brave

function sh_reset_chromium {
	local result

	if result=$(pidof chromium) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/chromium
	rm -r ~/.config/chromium-optimize
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/chromium ~/.config/chromium
	fi
	echo -n "#"
	return
}
export -f sh_reset_chromium

function sh_reset_clementine {
	local result

	if result=$(pidof clementine) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/Clementine
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/Clementine ~/.config/Clementine
	fi
	echo -n "#"
	return
}
export -f sh_reset_clementine

function sh_reset_dolphin {
	local result

	if result=$(pidof dolphin) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi
	rm -r ~/.local/share/kxmlgui5/dolphin
	rm -r ~/.local/share/dolphin
	rm ~/.config/session/dolphin_dolphin_dolphin
	rm ~/.config/dolphinrc
	if [ "$1" = "skel" ]; then
		cp -f /etc/skel/.config/dolphinrc ~/.config/dolphinrc
		cp -r /etc/skel/.local/share/kxmlgui5/dolphin ~/.local/share/kxmlgui5/dolphin
	fi
	echo -n "#"
	return
}
export -f sh_reset_dolphin

function sh_reset_firefox {
	local result

	if result=$(pidof firefox) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.mozilla
	echo -n "#"
	return
}
export -f sh_reset_firefox

function sh_reset_gimp {
	local result

	if result=$(pidof gimp-2.10) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/GIMP
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/GIMP ~/.config/GIMP
	fi
	echo -n "#"
	return
}
export -f sh_reset_gimp

function sh_reset_chrome {
	local result

	if result=$(pidof google-chrome) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi
	rm -r ~/.config/google-chrome
	echo -n "#"
	return
}
export -f sh_reset_chrome

function sh_reset_gwenview {
	local result

	if result=$(pidof gwenview) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.local/share/kxmlgui5/gwenview
	rm -r ~/.local/share/gwenview
	rm ~/.config/gwenviewrc
	if [[ "$1" = "skel" ]]; then
		cp -r /etc/skel/.local/share/kxmlgui5/gwenview ~/.local/share/kxmlgui5/gwenview
		cp -r /etc/skel/.local/share/gwenview ~/.local/share/gwenview
		cp -f /etc/skel/.config/gwenviewrc ~/.config/gwenviewrc
	fi
	echo -n "#"
	return
}
export -f sh_reset_gwenview

function sh_reset_inkscape {
	local result

	if result=$(pidof inkscape) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi
	rm -r ~/.config/inkscape
	echo -n "#"
	return
}
export -f sh_reset_inkscape

function sh_reset_kate {
	local result

	if result=$(pidof kate) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.local/share/kate
	rm -r ~/.local/share/kxmlgui5/kate
	rm -r ~/.local/share/kxmlgui5/katepart
	rm -r ~/.local/share/ktexteditor_snippets
	rm ~/.config/katevirc
	rm ~/.config/katemetainfos
	rm ~/.config/kateschemarc
	rm ~/.config/katesyntaxhighlightingrc
	rm ~/.config/katerc
	if [ "$1" = "skel" ]; then
		cp -f /etc/skel/.config/katevirc ~/.config/katevirc
		cp -f /etc/skel/.config/katemetainfos ~/.config/katemetainfos
		cp -f /etc/skel/.config/kateschemarc ~/.config/kateschemarc
		cp -f /etc/skel/.config/katesyntaxhighlightingrc ~/.config/katesyntaxhighlightingrc
		cp -f /etc/skel/.config/katerc ~/.config/katerc
		cp -r /etc/skel/.local/share/kate ~/.local/share/kate
		cp -r /etc/skel/.local/share/kxmlgui5/kate ~/.local/share/kxmlgui5/kate
		cp -r /etc/skel/.local/share/kxmlgui5/katepart ~/.local/share/kxmlgui5/katepart
		cp -r /etc/skel/.local/share/ktexteditor_snippets ~/.local/share/ktexteditor_snippets
	fi
	echo -n "#"
	return
}
export -f sh_reset_kate

function sh_reset_kde {
	local result

	if result=$(pidof dolphin) && [[ -n $result ]]; then
		kill -9 "$result"
		return
	fi

	#Remove(home) folders
	rm -r ~/.cache/*
	rm -r ~/.config/dconf
	rm -r ~/.config/gtk-3.0
	rm -r ~/.config/gtk-4.0
	rm -r ~/.config/KDE
	rm -r ~/.config/kde.org
	rm -r ~/.config/kdeconnect
	rm -r ~/.config/kdedefaults
	rm -r ~/.config/Kvantum
	rm -r ~/.config/latte
	rm -r ~/.config/pulse
	rm -r ~/.kdebiglinux
	rm -r ~/.local/share/kactivitymanagerd
	rm -r ~/.local/share/kcookiejar
	rm -r ~/.local/share/kded5
	rm -r ~/.local/share/knewstuff3
	rm -r ~/.local/share/konsole
	rm -r ~/.local/share/kpeoplevcard
	rm -r ~/.local/share/kscreen
	rm -r ~/.local/share/ksysguard
	rm -r ~/.local/share/kwalletd
	rm -r ~/.local/share/kwin
	rm -r ~/.local/share/kxmlgui5
	rm -r ~/.local/share/plasma_icons
	rm -r ~/.local/share/plasma

	#Remove(home) files
	rm ~/.bash_history
	rm ~/.bash_logout
	rm ~/.bashrc
	rm ~/.bash_profile
	rm ~/.big_desktop_theme
	rm ~/.big_performance
	rm ~/.big_preload
	rm ~/.gtkrc-2.0
	rm ~/.config/akregatorrc
	rm ~/.config/arkrc
	rm ~/.config/baloofileinformationrc
	rm ~/.config/baloofilerc
	rm ~/.config/bluedevilglobalrc
	rm ~/.config/breezerc
	rm ~/.config/drkonqirc
	rm ~/.config/gtkrc
	rm ~/.config/gtkrc-2.0
	rm ~/.config/latte
	rm ~/.config/kactivitymanagerdrc
	rm ~/.config/kcminputrc
	rm ~/.config/kconf_updaterc
	rm ~/.config/kded5rc
	rm ~/.config/kdeglobals
	rm ~/.config/kdialogrc
	rm ~/.config/kfontinstuirc
	rm ~/.config/kgammarc
	rm ~/.config/kglobalshortcutsrc
	rm ~/.config/khotkeysrc
	rm ~/.config/kiorc
	rm ~/.config/klaunchrc
	rm ~/.config/klassyrc
	rm ~/.config/kmenueditrc
	rm ~/.config/kmixrc
	rm ~/.local/share/krunnerstaterc
	rm ~/.config/kscreenlockerrc
	rm ~/.config/kservicemenurc
	rm ~/.config/ksmserverrc
	rm ~/.config/ksplashrc
	rm ~/.config/ksysguardrc
	rm ~/.config/ktimezonedrc
	rm ~/.config/kwalletrc
	rm ~/.config/kwinrc
	rm ~/.config/kwinrulesrc
	rm ~/.config/kxkbrc
	rm ~/.config/plasma-localerc
	rm ~/.config/plasma-nm
	rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
	rm ~/.config/plasma.emojierrc
	rm ~/.config/plasma_calendar_holiday_regions
	rm ~/.config/plasma_workspace.notifyrc
	rm ~/.config/plasmanotifyrc
	rm ~/.config/plasmarc
	rm ~/.config/plasmashellrc
	rm ~/.config/plasmavaultrc
	rm ~/.config/plasmawindowed-appletsrc
	rm ~/.config/plasmawindowedrc
	rm ~/.config/powerdevil.notifyrc
	rm ~/.config/powerdevilrc
	rm ~/.config/powermanagementprofilesrc
	rm ~/.config/spectaclerc
	rm ~/.config/systemmonitorrc
	rm ~/.config/systemsettingsrc
	rm ~/.config/Trolltech.conf
	rm ~/.config/xdg-desktop-portal-kderc
	rm ~/.local/share/RecentDocuments/*
	rm ~/.local/share/Trash/files/*

	#Copy(skel) folders
	cp -rf /etc/skel/.config ~
	cp -rf /etc/skel/.local ~
	cp -rf /etc/skel/.pje ~
	cp -rf /etc/skel/.pki ~

	#Copy(skel) files
	cp -f /etc/skel/.bash_logout ~
	cp -f /etc/skel/.bash_profile ~
	cp -f /etc/skel/.bashrc ~
	cp -f /etc/skel/.gtkrc-2.0 ~
	cp -f /etc/skel/.xinitrc ~

	#Default theme
	first-login-theme &>/dev/null

	#Compositing mode - based on biglinux-themes
	MODE="$(<$HOME/.big_performance)"
	if [ "$MODE" = "0" ]; then
		# Animation 0
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key AnimationSpeed 3
		kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key AnimationDurationFactor ""
		kwriteconfig5 --file ~/.config/klaunchrc --group BusyCursorSettings --key Blinking false
		kwriteconfig5 --file ~/.config/klaunchrc --group BusyCursorSettings --key Bouncing true

		# Composition on
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key Enabled true

		# Opengl 2
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key GLCore false
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key Backend OpenGL
	else
		# Animation 2
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key AnimationSpeed 1
		kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key AnimationDurationFactor 0.5
		kwriteconfig5 --file ~/.config/klaunchrc --group BusyCursorSettings --key Blinking true
		kwriteconfig5 --file ~/.config/klaunchrc --group BusyCursorSettings --key Bouncing false

		# Composition on
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key Enabled true

		# Opengl 2
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key GLCore false
		kwriteconfig5 --file ~/.config/kwinrc --group Compositing --key Backend OpenGL
	fi
	sleep 1
	echo -n "#"
	return
}
export -f sh_reset_kde

function sh_reset_konsole {
	local result

	if result=$(pidof konsole) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/konsole.knsrc
	rm -r ~/.config/konsolerc
	rm -r ~/.local/share/konsole
	rm -r ~/.local/share/kxmlgui5/konsole
	if [ "$1" = "skel" ]; then
		cp /etc/skel/.config/konsole.knsrc ~/.config/konsole.knsrc
		cp /etc/skel/.config/konsolerc ~/.config/konsolerc
		cp -r /etc/skel/.local/share/konsole ~/.local/share/konsole
	fi
	echo -n "#"
	return
}
export -f sh_reset_konsole

function sh_reset_ksnip {
	local result

	if result=$(pidof ksnip) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/ksnip
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/ksnip ~/.config/ksnip
	fi
	echo -n "#"
	return
}
export -f sh_reset_ksnip

function sh_reset_libreoffice {
	local result

	if result=$(pidof soffice.bin) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/libreoffice
	rm -r ~/.config/LanguageTool
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/libreoffice ~/.config/libreoffice
	fi
	echo -n "#"
	return
}
export -f sh_reset_libreoffice

function sh_reset_mystiq {
	local result

	if result=$(pidof mystiq) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/mystiq
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/mystiq ~/.config/mystiq
	fi
	echo -n "#"
	return
}
export -f sh_reset_mystiq

function sh_reset_okular {
	local result

	if result=$(pidof okular) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.local/share/kxmlgui5/okular
	rm -r ~/.local/share/okular
	rm ~/.config/okularpartrc
	rm ~/.config/okularrc
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.local/share/kxmlgui5/okular ~/.local/share/kxmlgui5/okular
		cp -f /etc/skel/.config/okularpartrc ~/.config/okularpartrc
		cp -f /etc/skel/.config/okularrc ~/.config/okularrc
	fi
	echo -n "#"
	return
}
export -f sh_reset_okular

function sh_reset_qbittorrent {
	local result

	if result=$(pidof qbittorrent) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/qBittorrent
	rm -r ~/.local/share/data/qBittorrent
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/qBittorrent ~/.config/qBittorrent
		cp -r /etc/skel/.local/share/data/qBittorrent ~/.local/share/data/qBittorrent
	fi
	echo -n "#"
	return
}
export -f sh_reset_qbittorrent

function sh_reset_smplayer {
	local result

	if result=$(pidof smplayer) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/smplayer
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/smplayer ~/.config/smplayer
	fi
	echo -n "#"
	return
}
export -f sh_reset_smplayer

function sh_reset_vokoscreenNG {
	local result

	if result=$(pidof vokoscreenNG) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/vokoscreenNG
	echo -n "#"
	return
}
export -f sh_reset_vokoscreenNG

function sh_reset_vlc {
	local result

	if result=$(pidof vlc) && [[ -n $result ]]; then
		echo -n "$result"
		return
	fi

	rm -r ~/.config/vlc
	if [ "$1" = "skel" ]; then
		cp -r /etc/skel/.config/vlc ~/.config/vlc
	fi
	echo -n "#"
	return
}
export -f sh_reset_vlc

########################################################################################################################

function sh_reset_xfce {
	local nPID

	if nPID=$(pidof dolphin) && [[ -n $nPID ]]; then
		kill -9 "$nPID"
		return
	fi

	#Remove(home) folders
	rm -r ~/.cache/*
	mv ~/.config/xfce4 /tmp/./config/xfce4_backup

	#Remove(home) files
	rm ~/.bash_history
	rm ~/.bash_logout
	rm ~/.bashrc
	rm ~/.bash_profile
	rm ~/.big_desktop_theme
	rm ~/.big_performance
	rm ~/.big_preload
	rm ~/.local/share/RecentDocuments/*
	rm ~/.local/share/Trash/files/*

	#Copy(skel) folders
	cp -rf /etc/skel/.config ~
	cp -rf /etc/skel/.local ~
	cp -rf /etc/skel/.pje ~
	cp -rf /etc/skel/.pki ~

	#Copy(skel) files
	cp -f /etc/skel/.bash_logout ~
	cp -f /etc/skel/.bash_profile ~
	cp -f /etc/skel/.bashrc ~
	cp -f /etc/skel/.xinitrc ~

	sleep 1
	echo -n "#"
	return
}
export -f sh_reset_xfce

########################################################################################################################

function sh_reset_gnome {
	local nPID

	if nPID=$(pidof dolphin) && [[ -n $nPID ]]; then
		kill -9 "$nPID"
		return
	fi

#	#Remove(home) folders
#	rm -r ~/.cache/*
#	mv ~/.config/xfce4 /tmp/./config/xfce4_backup
#
#	#Remove(home) files
#	rm ~/.bash_history
#	rm ~/.bash_logout
#	rm ~/.bashrc
#	rm ~/.bash_profile
#	rm ~/.big_desktop_theme
#	rm ~/.big_performance
#	rm ~/.big_preload
#	rm ~/.local/share/RecentDocuments/*
#	rm ~/.local/share/Trash/files/*
#
#	#Copy(skel) folders
#	cp -rf /etc/skel/.config ~
#	cp -rf /etc/skel/.local ~
#	cp -rf /etc/skel/.pje ~
#	cp -rf /etc/skel/.pki ~
#
#	#Copy(skel) files
#	cp -f /etc/skel/.bash_logout ~
#	cp -f /etc/skel/.bash_profile ~
#	cp -f /etc/skel/.bashrc ~
#	cp -f /etc/skel/.xinitrc ~

	sleep 1
	echo -n "#"
	return
}
export -f sh_reset_gnome

########################################################################################################################

function sh_reset_dde {
	local nPID

	if nPID=$(pidof dolphin) && [[ -n $nPID ]]; then
		kill -9 "$nPID"
		return
	fi

#	#Remove(home) folders
#	rm -r ~/.cache/*
#	mv ~/.config/xfce4 /tmp/./config/xfce4_backup
#
#	#Remove(home) files
#	rm ~/.bash_history
#	rm ~/.bash_logout
#	rm ~/.bashrc
#	rm ~/.bash_profile
#	rm ~/.big_desktop_theme
#	rm ~/.big_performance
#	rm ~/.big_preload
#	rm ~/.local/share/RecentDocuments/*
#	rm ~/.local/share/Trash/files/*
#
#	#Copy(skel) folders
#	cp -rf /etc/skel/.config ~
#	cp -rf /etc/skel/.local ~
#	cp -rf /etc/skel/.pje ~
#	cp -rf /etc/skel/.pki ~
#
#	#Copy(skel) files
#	cp -f /etc/skel/.bash_logout ~
#	cp -f /etc/skel/.bash_profile ~
#	cp -f /etc/skel/.bashrc ~
#	cp -f /etc/skel/.xinitrc ~

	sleep 1
	echo -n "#"
	return
}
export -f sh_reset_dde

########################################################################################################################

function sh_reset_palemoon() {
	local nPID

	if nPID=$(pidof palemoon) && [[ -n $nPID ]]; then
		echo -n "$nPID"
		return
	fi

	rm -r $HOME/'.moonchild productions'
	echo -n "#"
	return
}
export -f sh_reset_palemoon

########################################################################################################################

function sh_main {
   local execute_app="$1"
   local param_skel="$2"

   eval "$execute_app $param_skel"
   return
}

#sh_debug
sh_main "$@"
