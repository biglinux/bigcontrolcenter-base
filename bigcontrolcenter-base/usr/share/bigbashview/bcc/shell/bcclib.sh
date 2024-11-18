#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2094
#shellcheck source=/dev/null

#  bcclib.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2022/02/28
#  Altered: 2024/08/22
#
#  Copyright (c) 2023-2024, Vilmar Catafesta <vcatafesta@gmail.com>
#                2022-2023, Bruno Gonçalves <www.biglinux.com.br>
#                2022-2023, Rafael Ruscher <rruscher@gmail.com>
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

[[ -n "$LIB_BCCLIB_SH" ]] && return
LIB_BCCLIB_SH=1

APP="${0##*/}"
_VERSION_="1.0.0-20240822"
#BOOTLOG="/tmp/bigcontrolcenter-$USER-$(date +"%d%m%Y").log"
LOGGER='/dev/tty8'

# Definir a variável de controle para restaurar a formatação original
export reset=$(tput sgr0)

# Definir os estilos de texto como variáveis
export bold=$(tput bold)
export underline=$(tput smul)   # Início do sublinhado
export nounderline=$(tput rmul) # Fim do sublinhado
export reverse=$(tput rev)      # Inverte as cores de fundo e texto

# Definir as cores ANSI como variáveis
export black=$(tput bold)$(tput setaf 0)
export red=$(tput bold)$(tput setaf 196)
export green=$(tput bold)$(tput setaf 2)
export yellow=$(tput bold)$(tput setaf 3)
export blue=$(tput setaf 4)
export pink=$(tput setaf 5)
export magenta=$(tput setaf 5)
export cyan=$(tput setaf 6)
export white=$(tput setaf 7)
export gray=$(tput setaf 8)
export orange=$(tput setaf 202)
export purple=$(tput setaf 125)
export violet=$(tput setaf 61)
export light_red=$(tput setaf 9)
export light_green=$(tput setaf 10)
export light_yellow=$(tput setaf 11)
export light_blue=$(tput setaf 12)
export light_magenta=$(tput setaf 13)
export light_cyan=$(tput setaf 14)
export bright_white=$(tput setaf 15)
#
export COL_NC='\e[0m' # No Color
export COL_LIGHT_GREEN='\e[1;32m'
export COL_LIGHT_RED='\e[1;31m'
export TICK="${white}[${COL_LIGHT_GREEN}✓${COL_NC}${white}]"
export CROSS="${white}[${COL_LIGHT_RED}✗${COL_NC}${white}]"
export INFO="[i]"

log_info() {
	printf " %b %s\\n" "${INFO}" "${*}"
}
export -f log_info

log_msg() {
	printf " %b %s\\n" "${TICK}" "${*}"
}
export -f log_msg

log_err() {
	printf " %b %s\\n" "${CROSS}" "${*}"
}
export -f log_err

function sh_diahora {
	DIAHORA=$(date +"%d%m%Y-%T" | sed 's/://g')
	printf "%s\n" "$DIAHORA"
}
export -f sh_diahora

function sh_debug {
	export PS4='${red}${0##*/}${green}[$FUNCNAME]${pink}[$LINENO]${reset} '
	set -x
	#set -e
	#shopt -s extglob
	#Only to debug
	#rm -R "$HOME/.config/bigcontrolcenter/"
	#Don't group windows
	#xprop -id "$(xprop -root '\t$0' _NET_ACTIVE_WINDOW | cut -f 2)" -f WM_CLASS 8s -set WM_CLASS "$$"
}

# determina se o fundo do KDE está em modo claro ou escuro
function sh_getbgcolor {
	local cfile="$HOME/.config/bigbashview_lightmode"
	local lightmode=0
	local result
	local r g b
	local average_rgb

	if [[ -f "$cfile" ]]; then
		lightmode=$(<"$cfile")
	else
		# Read background color RGB values
		if result=$(kreadconfig5 --group "Colors:Window" --key BackgroundNormal) && [[ -n "$result" ]]; then
			r=${result%,*}
			g=${result#*,}
			g=${g%,*}
			b=${result##*,}
			average_rgb=$(((r + g + b) / 3))

			if ((average_rgb > 127)); then
				lightmode=1
			fi
		fi
		echo "$lightmode" >"$cfile"
	fi

	if ((lightmode)); then
		echo '<body class=light-mode>'
	else
		echo '<body>'
	fi
}
export -f sh_getbgcolor

function sh_setbgcolor {
	local cfile="$HOME/.config/bigbashview_lightmode"
	local lightmode=0

	[[ "$1" = "true" ]] && lightmode=1
	echo "$lightmode" >"$cfile"
}
export -f sh_setbgcolor

function sh_lang_he {
	grep ^he <<<"$LANG"
	return "$?"
}
export -f sh_lang_he

function sh_get_locale {
	grep _ <(locale -a) | head -1 | cut -c1-5
}
export -f sh_get_locale

function sh_get_code_lang {
	local LangFilter="${LANG%%.*}"
	local LangFilterLowercase="${LangFilter,,}"
	local LangClean="${LangFilterLowercase%%_*}"
	local LangCountry="${LangFilterLowercase#*_}"
	local LangFilterLowercaseModified="${LangFilterLowercase//_/-}"
	echo "$LangFilterLowercaseModified"
}
export -f sh_get_code_lang

function sh_get_lang {
	echo "$LANG"
}
export -f sh_get_lang

function sh_get_lang_without_utf8 {
	echo "${LANG%%.*}"
}
export -f sh_get_lang_without_utf8

function sh_get_code_language {
	local LangFilter="${LANGUAGE%%.*}"
	local LangFilterLowercase="${LangFilter,,}"
	local LangClean="${LangFilterLowercase%%_*}"
	local LangCountry="${LangFilterLowercase#*_}"
	local LangFilterLowercaseModified="${LangFilterLowercase//_/-}"
	echo "$LangFilterLowercaseModified"
}
export -f sh_get_code_language

function sh_get_language {
	echo "$LANGUAGE"
}
export -f sh_get_language

function sh_get_language_without_utf8 {
	echo "${LANGUAGE%%.*}"
}
export -f sh_get_language_without_utf8

function sh_getcpu {
	#awk -F ':' 'NR==1 {print $2}' <<< "$(grep 'model name' /proc/cpuinfo)"
	grep 'model name' /proc/cpuinfo | awk -F ':' 'NR==1 {print $2}'
}
export -f sh_getcpu

function sh_getmemory {
	awk -F' ' 'NR==2 {print $2}' < <(free -h)
}
export -f sh_getmemory

function sh_getvga {
	awk -F: '/VGA/ {print $3}' < <(lspci)
}
export -f sh_getvga

function sh_catecho {
	echo "$(<"$1")"
}
export -f sh_catecho

function sh_catprintf {
	printf "%s" "$(<"$1")"
}
export -f sh_catprintf

function sh_printfile {
	sh_catecho "$1"
}
export -f sh_printfile

function sh_installed_pkgs {
	pacman -Q | cut -f1 -d" "
}
export -f sh_installed_pkgs

function sh_info_msg {
	#  echo -e "\033[1m$*\033[m"
	printf '\033[1m%b\033[m' "$@"
}
export -f sh_info_msg

function sh_get_greeting_message {
	local -i hora_atual
	local greeting_message

	hora_atual=$(date +%k)
	if ((hora_atual >= 6 && hora_atual < 12)); then
		greeting_message=$"Bom dia"
	elif ((hora_atual >= 12 && hora_atual < 18)); then
		greeting_message=$"Boa tarde"
	else
		greeting_message=$"Boa noite"
	fi
	echo "$greeting_message"
}
export -f sh_get_greeting_message

function sh_get_user {
	[[ "$USER" != "biglinux" ]] && echo " $USER"
}
export -f sh_get_user

function sh_ignore_error {
	"$@" 2>/dev/null
	return 0
}
export -f sh_ignore_error

function sh_div_lang {
	if grep -q ^he <<<"$LANG"; then
		echo '<div class="wrapper" style="flex-direction: row-reverse;">'
	else
		echo '<div class="wrapper">'
	fi
}
export -f sh_div_lang

function info {
	whiptail \
		--fb \
		--clear \
		--backtitle "[debug]$0" \
		--title "[debug]$0" \
		--yesno "${*}\n" \
		0 40
	result=$?
	if ((result)); then
		exit
	fi
	return $result
}
export -f info

function sh_splitarray {
	local str=("$1")
	local pos="$2"
	local sep="${3:-'|'}"
	local array

	[[ $# -eq 3 && "$pos" = "|" && "$sep" =~ ^[0-9]+$ ]] && {
		sep="$2"
		pos="$3"
	}
	[[ $# -eq 2 && "$pos" = "$sep" ]] && {
		sep="$pos"
		pos=1
	}
	[[ $# -eq 1 || ! "$pos" =~ ^[0-9]+$ ]] && { pos=1; }

	IFS="$sep" read -r -a array <<<"${str[@]}"
	echo "${array[pos - 1]}"
}
export -f sh_splitarray

function sh_linuxHardware_run { sh_linuxHardware "$@"; }
function sh_linuxhardware_run { sh_linuxHardware "$@"; }
function sh_linuxhardware { sh_linuxHardware "$@"; }
function sh_linuxHardware {
	if [ $# -gt 0 ]; then
		xdg-open https://linux-hardware.org/?id="$*"
	fi
}
export -f sh_linuxHardware

function sh_replace_variables {
	local text="$1"
	while [[ $text =~ \$([A-Za-z_][A-Za-z_0-9]*) ]]; do
		local variable_name="${BASH_REMATCH[1]}"
		local variable_value="${!variable_name}"
		text="${text/\$$variable_name/$variable_value}"
	done
	echo "$text"
}
export -f sh_replace_variables

function sh_with_echo {
	local HTML_CONTENT="$1"
	local evaluated_text=$(sh_replace_variables "$HTML_CONTENT")
	echo "$evaluated_text"
}
export -f sh_with_echo

function sh_with_read {
	local HTML_CONTENT
	read -d $'' -r HTML_CONTENT <<-EOF
		$1
	EOF
	local evaluated_text=$(sh_replace_variables "$HTML_CONTENT")
	echo "$evaluated_text"
}
export -f sh_with_read

function sh_with_cat {
	cat <<-EOF
		$(sh_replace_variables "$1")
	EOF
}
export -f sh_with_cat

function sh_window_id {
	xprop -root '\t$0' _NET_ACTIVE_WINDOW | cut -f 2
}
export -f sh_window_id

function sh_get_window_id {
	xprop -root '\t$0' _NET_ACTIVE_WINDOW | cut -f 2
}
export -f sh_get_window_id

function xdebug {
	local script_name0="${0##*/}[${FUNCNAME[1]}:${BASH_LINENO[1]}]"
	local script_name1="${0##*/}[${FUNCNAME[0]}:${BASH_LINENO[0]}]"
	local script_name2="${0##*/}[${FUNCNAME[2]}:${BASH_LINENO[2]}]"
	# Obter a largura da tela em pixels usando xrandr
	local screen_width=$(xrandr | grep '*' | awk '{print $1}' | cut -d 'x' -f1)
	# Calcular 75% da largura da tela
	local width=$((screen_width * 75 / 100))

	#	kdialog --title "[xdebug (kdialog)]$0" \
	#		--yes-label="Não" \
	#		--no-label="Sim" \
	#		--warningyesno "\n${*}\n\nContinuar ?\n"
	#	result=$?
	#	[[ $result -eq 0 ]] && exit 1 # botões invertidos
	#	return $result
	#
	yad --title="xdebug (yad):$script_name0->$script_name1" \
		--text="${*}\n\nContinuar ?" \
		--center \
		--width=$width \
		--fontname="Ubuntu Condensed 10" \
		--window-icon="$xicon" \
		--buttons-layout=center \
		--on-top \
		--selectable-labels \
		--button="Sim:0" \
		--button="Não:1"
	result=$?
	[[ $result -eq 1 ]] && exit 1
	return $result
}
export -f xdebug
#		--close-on-unfocus \

function log_error {
	#	printf "%s %-s->%-s->%-s : %s => %s\n" "$(date +"%H:%M:%S")" "$1" "$2" "$3" "$4" "$5" >> "$BOOTLOG"
	printf "%s %-s->%-s->%-s : %s => %s\n" "$(date +"%H:%M:%S")" "$1" "$2" "$3" "$4" "$5" | tee -i -a "$BOOTLOG" >$LOGGER
}
export -f log_error

function cmdlogger {
	#	local lastcmd="$@"
	local lastcmd="$*"
	local status
	local error_output
	local script_name0="${0##*/}[${FUNCNAME[0]}]:${BASH_LINENO[0]}"
	local script_name1="${0##*/}[${FUNCNAME[1]}]:${BASH_LINENO[1]}"
	local script_name2="${0##*/}[${FUNCNAME[2]}]:${BASH_LINENO[2]}"

	error_output=$("$@" 2>&1)
	#  status="${PIPESTATUS[0]}"
	status="$?"
	if [ $status -ne 0 ]; then
		error_output=$(echo "$error_output" | cut -d':' -f3-)
		log_error "$script_name2" "$script_name1" "$script_name0" "$lastcmd" "$error_output"
	fi
	return $status
}
export -f cmdlogger

function sh_kscreen_clean {
	local xicon="$1"
	local xtitle=$"Configurações da tela"
	local xmsgbox=$"As configurações da tela foram resetadas."

	rm -Rf ~/.local/share/kscreen
	#	kdialog --msgbox "$xmsgbox" --title "$xtitle" --icon "$xicon" &
	yad --title="$xtitle" --text="\n$xmsgbox" --width=400 --window-icon="$xicon" --button="OK:0" &
	sleep 5
	wmctrl -c "$xtitle"
}
export -f sh_kscreen_clean

function sh_get_current_desktop {
	echo "$XDG_CURRENT_DESKTOP"
}
export -f sh_get_current_desktop

function sh_get_wm {
	local ps_flags=(-e)

	if [[ -O "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY:-wayland-0}" ]]; then
		if tmp_pid="$(lsof -t "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY:-wayland-0}" 2>&1)" ||
			tmp_pid="$(fuser "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY:-wayland-0}" 2>&1)"; then
			wm="$(ps -p "${tmp_pid}" -ho comm=)"
		else
			# lsof may not exist, or may need root on some systems. Similarly fuser.
			# On those systems we search for a list of known window managers, this can mistakenly
			# match processes for another user or session and will miss unlisted window managers.
			#			wm=$(ps "${ps_flags[@]}" | grep -m 1 -o -F \
			wm=$(pgrep -f "${ps_flags[@]}" \
				-e arcan \
				-e asc \
				-e clayland \
				-e dwc \
				-e fireplace \
				-e gnome-shell \
				-e greenfield \
				-e grefsen \
				-e hikari \
				-e kwin \
				-e lipstick \
				-e maynard \
				-e mazecompositor \
				-e motorcar \
				-e orbital \
				-e orbment \
				-e perceptia \
				-e river \
				-e rustland \
				-e sway \
				-e ulubis \
				-e velox \
				-e wavy \
				-e way-cooler \
				-e wayfire \
				-e wayhouse \
				-e westeros \
				-e westford \
				-e weston 2>/dev/null)
		fi

	elif [[ $DISPLAY && $os != "Mac OS X" && $os != "macOS" && $os != FreeMiNT ]]; then
		# non-EWMH WMs.
		#		wm=$(ps "${ps_flags[@]}" | grep -m 1 -o \
		wm=$(pgrep -f "${ps_flags[@]}" \
			-e "[s]owm" \
			-e "[c]atwm" \
			-e "[f]vwm" \
			-e "[d]wm" \
			-e "[2]bwm" \
			-e "[m]onsterwm" \
			-e "[t]inywm" \
			-e "[x]11fs" \
			-e "[x]monad" 2>/dev/null)

		[[ -z $wm ]] && type -p xprop &>/dev/null && {
			id=$(xprop -root -notype _NET_SUPPORTING_WM_CHECK)
			id=${id##* }
			wm=$(xprop -id "$id" -notype -len 100 -f _NET_WM_NAME 8t)
			wm=${wm/*WM_NAME = /}
			wm=${wm/\"/}
			wm=${wm/\"*/}
		}
	fi
	[[ $wm == *WINDOWMAKER* ]] && wm=wmaker
	[[ $wm == *GNOME*Shell* ]] && wm=Mutter
}
export -f sh_get_wm

function sh_get_de {
	sh_get_wm
	# Temporary support for Regolith Linux
	if [[ $DESKTOP_SESSION == *regolith ]]; then
		de=Regolith

	elif [[ $XDG_CURRENT_DESKTOP ]]; then
		de=${XDG_CURRENT_DESKTOP/X\-/}
		de=${de/Budgie:GNOME/Budgie}
		de=${de/:Unity7:ubuntu/}

	elif [[ $DESKTOP_SESSION ]]; then
		de=${DESKTOP_SESSION##*/}

	elif [[ $GNOME_DESKTOP_SESSION_ID ]]; then
		de=GNOME

	elif [[ $MATE_DESKTOP_SESSION_ID ]]; then
		de=MATE

	elif [[ $TDE_FULL_SESSION ]]; then
		de=Trinity
	fi

	[[ $de == "$wm" ]] && {
		unset -v de
		return
	}
	# Fallback to using xprop.
	[[ $DISPLAY && -z $de ]] && type -p xprop &>/dev/null &&
		de=$(xprop -root | awk '/KDE_SESSION_VERSION|^_MUFFIN|xfce4|xfce5/')

	# Format strings.
	case $de in
	KDE_SESSION_VERSION*) de=KDE${de/* = /} ;;
	*xfce4*) de=Xfce4 ;;
	*xfce5*) de=Xfce5 ;;
	*xfce*) de=Xfce ;;
	*mate*) de=MATE ;;
	*GNOME*) de=GNOME ;;
	*MUFFIN*) de=Cinnamon ;;
	esac

	((${KDE_SESSION_VERSION:-0} >= 4)) && de=${de/KDE/Plasma}

	if [[ $de_version == on && $de ]]; then
		case $de in
		Plasma*) de_ver=$(plasmashell --version) ;;
		MATE*) de_ver=$(mate-session --version) ;;
		Xfce*) de_ver=$(xfce4-session --version) ;;
		GNOME*) de_ver=$(gnome-shell --version) ;;
		Cinnamon*) de_ver=$(cinnamon --version) ;;
		Deepin*) de_ver=$(awk -F'=' '/MajorVersion/ {print $2}' /etc/os-version) ;;
		Budgie*) de_ver=$(budgie-desktop --version) ;;
		LXQt*) de_ver=$(lxqt-session --version) ;;
		Lumina*) de_ver=$(lumina-desktop --version 2>&1) ;;
		Trinity*) de_ver=$(tde-config --version) ;;
		Unity*) de_ver=$(unity --version) ;;
		esac

		de_ver=${de_ver/*TDE:/}
		de_ver=${de_ver/tde-config*/}
		de_ver=${de_ver/liblxqt*/}
		de_ver=${de_ver/Copyright*/}
		de_ver=${de_ver/)*/}
		de_ver=${de_ver/* /}
		de_ver=${de_ver//\"/}

		de+=" $de_ver"
	fi

	[[ $de && $WAYLAND_DISPLAY ]] && de+=" (Wayland)"
	echo $de
}
export -f sh_get_de

# ter 15 ago 2023 23:45:22 -04
# Função que aceita múltiplas linhas de entrada e imprime sem aspas e escapes um bloco de texto, similar ao cat, porém usando o printf
function sh_print_multiline {
	while IFS= read -r line || [[ -n "$line" ]]; do
		printf '%s\n' "$line"
	done
}
export -f sh_print_multiline

# qua 16 ago 2023 01:25:39 -04
# Função para interpretar o conteúdo e substituir variáveis
function sh_catp {
	eval "content=\$(cat <<-'EOF'
      $(cat)
EOF
   )"
	#  sh_print_multiline <<< "$content" | sed 's/^[[:blank:]]*//'
	printf '\n%s\n' "<!-- INIT_BLOCK => ${0##*/}[${FUNCNAME[1]}]:${BASH_LINENO[0]} -->$line"
	while IFS= read -r line; do
		#		line="${line#"${line%%[![:space:]]*}"}"
		printf '\t%s\n' "$line"
	done <<<"$content"
	printf '\n%s\n' "<!-- END_BLOCK  => ${0##*/}[${FUNCNAME[1]}]:${BASH_LINENO[0]} -->$line"
}
export -f sh_catp

function sh_run_action_standalone {
	local cmd="$*"
	shift
	local retval
	export WINDOW_ID

	[[ -z "$WINDOW_ID" ]] && WINDOW_ID="$(sh_window_id)"
	export PID_BIG_DEB_INSTALLER="$$"
	export MARGIN_TOP_MOVE=-90
	export WINDOW_HEIGHT=12

	#    -fg rgb:ff/ff/ff \
	#    -bg rgb:ff/00/00 \

	urxvt +sb \
		-internalBorder 2 \
		-borderColor rgb:00/22/40 \
		-depth 32 \
		-fg rgb:ff/ff/ff \
		-bg rgb:00/00/00 \
		-fn "xft:Ubuntu Mono:pixelsize=12" \
		-embed "$WINDOW_ID" \
		-sr \
		-bc \
		-title "$cmd" \
		-e bash -c "sh_install_terminal_fixed & $cmd $*"
	#		-e bash -c "MARGIN_TOP_MOVE=-90 WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER=$$ WINDOW_ID=$WINDOW_ID sh_install_terminal_resize & $cmd $@"
	return $?
}
export -f sh_run_action_standalone

function sh_run_action {
	local action="$1"
	local window_id="$2"
	local package_name="$3"
	local package_id="$4"
	local repository="$5"
	local driver="$6"

	[[ -z "$window_id" ]] && window_id="$(sh_window_id)"
	ACTION="$action"
	WINDOW_ID="$window_id"
	PACKAGE_NAME="$package_name"
	PACKAGE_ID="$package_id"
	REPOSITORY="$repository"
	DRIVER="$driver"
	urxvt +sb \
		-internalBorder 1 \
		-borderColor rgb:00/22/40 \
		-depth 32 \
		-fg rgb:00/ff/ff \
		-bg rgb:00/22/40 \
		-fn "xft:Ubuntu Mono:pixelsize=12" \
		-embed "$WINDOW_ID" \
		-sr \
		-bc -e bash -c "sh_install_terminal $ACTION $WINDOW_ID $PACKAGE_NAME $PACKAGE_ID $REPOSITORY $DRIVER"
	#           -bc -e bash -c "sh_install_terminal "$ACTION" "$WINDOW_ID""
	#           -bc -e "${LIBRARY}/bcclib.sh" sh_install_terminal "$ACTION" "$WINDOW_ID"
}
export -f sh_run_action

function sh_install_terminal_resize {
	while :; do
		# Obtém a altura da janela referenciada por $WINDOW_ID
		WINDOW_HEIGHT_DETECT=$(xwininfo -id $WINDOW_ID | awk '/Height:/ {print $2}')
		# Obtém a largura da janela referenciada por $WINDOW_ID
		WINDOW_WIDTH=$(xwininfo -id $WINDOW_ID | awk '/Width:/ {print $2}')
		# Calcula 7% da largura da janela para definir a largura do terminal
		WIDTH_TERMINAL=$((WINDOW_WIDTH * 12 / 100))
		# Calcula 15% da largura da janela para definir a margem esquerda
		MARGIN_LEFT=$((WINDOW_WIDTH * 12 / 100))
		# Calcula a margem superior como 50% da altura da janela mais um valor adicional
		MARGIN_TOP=$((WINDOW_HEIGHT_DETECT * 5 / 10 + MARGIN_TOP_MOVE))
		# Define as dimensões e a posição da janela do terminal
		# WIDTH_TERMINAL: Largura do terminal (7% da largura da janela original)
		# WINDOW_HEIGHT: Altura do terminal (igual à altura da janela original)
		# MARGIN_LEFT: Margem esquerda (15% da largura da janela original)
		# MARGIN_TOP: Margem superior calculada (50% da altura da janela original + MARGIN_TOP_MOVE)
		xtermset -geom ${WIDTH_TERMINAL}x${WINDOW_HEIGHT}+${MARGIN_LEFT}+${MARGIN_TOP}
		sleep 0.2

		# if close bigbashview window, kill terminal too
		if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
			kill -9 $PID_TERM_BIG_STORE
			exit 0
		fi
	done
}
export -f sh_install_terminal_resize

function sh_install_terminal_fixed {
	# Obtém a altura da janela referenciada por $WINDOW_ID
	WINDOW_HEIGHT_DETECT=$(xwininfo -id $WINDOW_ID | awk '/Height:/ {print $2}')
	# Obtém a largura da janela referenciada por $WINDOW_ID
	WINDOW_WIDTH=$(xwininfo -id $WINDOW_ID | awk '/Width:/ {print $2}')
	# Calcula 7% da largura da janela para definir a largura do terminal
	WIDTH_TERMINAL=$((WINDOW_WIDTH * 12 / 100))
	# Calcula 15% da largura da janela para definir a margem esquerda
	MARGIN_LEFT=$((WINDOW_WIDTH * 12 / 100))
	# Calcula a margem superior como 50% da altura da janela mais um valor adicional
	MARGIN_TOP=$((WINDOW_HEIGHT_DETECT * 5 / 10 + MARGIN_TOP_MOVE - 40))
	# Define as dimensões e a posição da janela do terminal
	# WIDTH_TERMINAL: Largura do terminal (7% da largura da janela original)
	# WINDOW_HEIGHT: Altura do terminal (igual à altura da janela original)
	# MARGIN_LEFT: Margem esquerda (15% da largura da janela original)
	# MARGIN_TOP: Margem superior calculada (50% da altura da janela original + MARGIN_TOP_MOVE)

	((WINDOW_HEIGHT += 20))
	xtermset -geom ${WIDTH_TERMINAL}x${WINDOW_HEIGHT}+${MARGIN_LEFT}+${MARGIN_TOP}
	sleep 0.2

	# if close bigbashview window, kill terminal too
	if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
		kill -9 $PID_TERM_BIG_STORE
		exit 0
	fi
}
export -f sh_install_terminal_fixed

function sh_install_terminal {
	[[ -z "$ACTION" ]] && ACTION="$1"
	[[ -z "$WINDOW_ID" ]] && WINDOW_ID="$2"
	[[ -z "$PACKAGE_NAME" ]] && PACKAGE_NAME="$3"
	[[ -z "$PACKAGE_ID" ]] && PACKAGE_ID="$4"
	[[ -z "$REPOSITORY" ]] && REPOSITORY="$5"
	[[ -z "$DRIVER" ]] && DRIVER="$6"

	if [[ -n "$ACTION" ]]; then
		MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" sh_install_terminal_resize &

		case "$ACTION" in
		"reinstall_pamac") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac reinstall $PACKAGE_NAME --no-confirm ;;
		"install_flatpak")
			pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY flatpak install --or-update $REPOSITORY $PACKAGE_ID -y
			if [ ! -e "$HOME_FOLDER/disable_flatpak_unused_remove" ]; then
				flatpak uninstall --unused -y
			fi
			#			sh_update_cache_flatpak
			;;
		"remove_flatpak")
			pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY flatpak remove $PACKAGE_ID -y
			if [ ! -e "$HOME_FOLDER/disable_flatpak_unused_remove" ]; then
				flatpak uninstall --unused -y
			fi
			#			sh_update_cache_flatpak
			;;
		"install_snap")
			if [[ ! -e "$HOME_FOLDER/disable_snap_unused_remove" ]]; then
				pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" snap install "$PACKAGE_NAME"
				sh_snap_clean
			else
				snap install "$PACKAGE_NAME"
				sh_snap_clean
			fi
			;;
		"remove_snap")
			if [[ ! -e "$HOME_FOLDER/disable_snap_unused_remove" ]]; then
				pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" snap remove "$PACKAGE_NAME"
			else
				snap remove $PACKAGE_NAME
			fi
			;;
			#		"update_pacman") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bigsudo pacman -Syy --noconfirm ;;
		"update_pacman")
			sh_pkexec pacman -Syy --noconfirm
			TIni.Set "$INI_FILE_BIG_STORE" "nativo" "nativo_atualizado" '1'
			TIni.Set "$INI_FILE_BIG_STORE" "nativo" "nativo_data_atualizacao" "$(date "+%d/%m/%y %H:%M")"
			;;
		"update_pamac")
			#			pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac update --force-refresh --download-only --no-confirm
			sh_pkexec pamac update --force-refresh --download-only --no-devel
			TIni.Set "$INI_FILE_BIG_STORE" "PAMAC" "pamac_atualizado" '1'
			TIni.Set "$INI_FILE_BIG_STORE" "PAMAC" "pamac_data_atualizacao" "$(date "+%d/%m/%y %H:%M")"
			;;
		"update_mirror") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pacman-mirrors --geoip ;;
		"update_keys") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --fix-keys ;;
		"force_upgrade") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --upgrade-now ;;
		"reinstall_allpkg") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY sh_reinstall_allpkg ;;
		"system_upgrade") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac update --no-confirm ;;
		"system_upgradetotal") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bigsudo pacman -Syyu --noconfirm ;;
		"update_flatpak") env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY sh_update_cache_flatpak ;;
		"update_snap") sh_update_cache_snap ;;
		"enable_snapd") sh_enable_snapd_and_apparmor ;;
		esac
	fi

	if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
		kill -9 $PID_BIG_DEB_INSTALLER
		exit 0
	fi
}
export -f sh_install_terminal

########################################################################################################################
function sh_pkexec() {
	pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY KDE_SESSION_VERSION=5 KDE_FULL_SESSION=true ${1+"$@"}
}
export -f sh_pkexec

########################################################################################################################
function sh_sudo_pkexec() {
	local cmd="$1"

	pkexec \
		env DISPLAY=$DISPLAY \
		XAUTHORITY=$XAUTHORITY \
		KDE_SESSION_VERSION=5 \
		KDE_FULL_SESSION=true \
		bash -c "$(declare -f "$cmd"); $cmd $*"
}
export -f sh_sudo_pkexec

########################################################################################################################
function sh_export_pkexec() {
	local cmd="$1"
	shift

	# Captura as variáveis exportadas e as funções definidas
	local exports=$(export -p)
	local functions=$(declare -f)
	# Passa tudo para o shell chamado pelo pkexec
	pkexec bash -c "$exports; $functions; $cmd $*"
}
export -f sh_export_pkexec

########################################################################################################################
function sh_SaveAndExport_pkexec() {
	local cmd="$1"
	shift

	# Cria um arquivo temporário para armazenar as variáveis e funções exportadas
	local tmpfile=$(mktemp)

	# Salva o ambiente e as funções no arquivo temporário
	{
		export -p
		declare -f
	} >"$tmpfile"

	# Executa o comando com pkexec, carregando o ambiente do arquivo temporário
	pkexec bash -c "source '$tmpfile'; $cmd $*"

	# Remove o arquivo temporário após a execução
	rm -f "$tmpfile"
}
export -f sh_SaveAndExport_pkexec

########################################################################################################################
function sh_get_desktop_session() {
	echo "$XDG_SESSION_TYPE"
}
export -f sh_get_desktop_session

########################################################################################################################
function sh_pkexec_which_result() {
	local cmd="$1"
	shift

	# Cria um arquivo temporário para armazenar as variáveis e funções exportadas
	local tmpfile=$(mktemp)
	local tmpresult=$(mktemp)
	local result

	# Salva o ambiente e as funções no arquivo temporário
	{
		export -p
		declare -f
	} >"$tmpfile"

	# Executa o comando com pkexec, capturando o código de saída
	pkexec bash -c "source '$tmpfile'; $cmd $*; exit_code=\$?; echo \$exit_code" >"$tmpresult"

	# Lê o código de saída do arquivo temporário
	local result=$(<"$tmpresult")

	# Remove o arquivo temporário após a execução
	rm -f "$tmpfile" "$tmpresult"

	# Retorna o código de saída
	return $result
}
export -f sh_pkexec_which_result

########################################################################################################################

# Função que exibe um diálogo de senha
function sh_gui_as_root() {
	local cmd="$1"
	local senha
	local title="Digite sua senha"
	local text="Authentication is needed to run '$cmd' as the super user\n\n
Um aplicativo está tentanto executar uma ação que requer privilégios. É necessária\nautenticação para executar essa ação."

#	senha=$(zenity --password --title="Digite sua senha")
	senha=$(yad \
						--center \
						--on-top \
						--title="$title" \
						--entry \
						--hide-text \
						--text="$text" \
						--width=450 \
						--height=100
					)

	if [ $? -eq 0 ] && [ -n "$senha" ]; then
		#zenity --info --text="Senha correta! Acesso concedido."
		echo "$senha" | sudo -S bash -c "$(declare -f "$cmd"); $*"
	else
		zenity --error --text="Senha incorreta ou não digitada!\nAcesso negado."
	fi
}
export -f sh_gui_as_root

########################################################################################################################
function sh_main {
	local execute_app="$1"

	if test $# -ge 1; then
		shift
		eval "$execute_app"
	fi
	#  return
}

########################################################################################################################

#sh_debug
#sh_main "$@"
