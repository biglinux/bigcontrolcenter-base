#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2094
#shellcheck source=/dev/null

#  weblib.sh
#  Description: Library for BigLinux WebApps
#
#  Created: 2024/05/31
#  Altered: 2024/06/04
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

[[ -n "$LIB_WEBLIB_SH" ]] && return
LIB_WEBLIB_SH=1

APP="${0##*/}"
_VERSION_="1.0.0-20240604"
#
export BOOTLOG="/tmp/bigwebapps-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
export HOME_FOLDER="$HOME/.bigwebapps"
export HOME_LOCAL="$HOME/.local"
export TMP_FOLDER="/tmp/bigwebapps-$USER"
export INI_FILE_WEBAPPS="$HOME_FOLDER/bigwebapps.ini"

# Configurações de tradução
export TEXTDOMAINDIR="/usr/share/locale" # Define o diretório de domínios de texto para traduções
export TEXTDOMAIN=biglinux-webapps       # Define o domínio de texto para o aplicativo

#Título do aplicativo
export TITLE="BigLinux WebApps" # Define o título do aplicativo
export BUTTON_FECHAR="$(gettext $"Fechar")"

# Caminho para os webapps do BigLinux
export WEBAPPS_PATH="/usr/share/bigbashview/bcc/apps/biglinux-webapps"
export webapps_path="$WEBAPPS_PATH"

#colors
export red=$(tput setaf 124)
export green=$(tput setaf 2)
export pink=$(tput setaf 129)
export reset=$(tput sgr0)

# Mensagens de erro traduzidas
export Amsg=(
	[error_open]=$(gettext $"Outra instância do Gerenciador de WebApps já está em execução.") # Mensagem de erro para instância já em execução
	[error_access_dir]=$(gettext $"Erro ao acessar o diretório:")                             # Mensagem de erro para falha ao acessar diretório
	[error_browser]=$(gettext $"O browser configurado como padrão em $INI_FILE_WEBAPPS não está instalado ou tem um erro de configuração.\nClique em fechar para definir para o padrão do BigLinux e continuar!")
)
export aBrowserId=('brave' 'brave' 'google-chrome-stable' 'chromium' 'microsoft-edge-stable' 'firefox' 'falkon' 'librewolf' 'vivaldi-stable' 'com.brave.Browser' 'com.google.Chrome' 'org.chromium.Chromium' 'com.microsoft.Edge' 'org.gnome.Epiphany' 'org.mozilla.firefox' 'io.gitlab.librewolf-community' 'com.github.Eloston.UngoogledChromium')
export aBrowserIcon=('brave' 'brave' 'chrome' 'chromium' 'edge' 'firefox' 'falkon' 'librewolf' 'vivaldi' 'brave' 'chrome' 'chromium' 'edge' 'epiphany' 'firefox' 'librewolf' 'ungoogled')
export aBrowserTitle=('BRAVE' 'BRAVE' 'CHROME' 'CHROMIUM' 'EDGE' 'FIREFOX' 'FALKON' 'LIBREWOLF' 'VIVALDI' 'BRAVE (FlatPak)' 'CHROME (FlatPak)' 'CHROMIUM (FlatPak)' 'EDGE (FlatPak)' 'EPIPHANY (FlatPak)' 'FIREFOX (FlatPak)' 'LIBREWOLF (FlatPak)' 'UNGOOGLED (FlatPak)')
export aBrowserCompatible=('1' '1' '1' '1' '1' '1' '1' '1' '1' '1' '1' '1' '1' '0' '1' '1' '1')
export aBrowserPath=(
	'/usr/lib/brave-browser/brave'
	'/opt/brave-bin/brave'
	'/opt/google/chrome/google-chrome'
	'/usr/lib/chromium/chromium'
	'/opt/microsoft/msedge/microsoft-edge'
	'/usr/lib/firefox/firefox'
	'/usr/bin/falkon'
	'/usr/lib/librewolf/librewolf'
	'/opt/vivaldi/vivaldi'
	'/var/lib/flatpak/exports/bin/com.brave.Browser'
	'/var/lib/flatpak/exports/bin/com.google.Chrome'
	'/var/lib/flatpak/exports/bin/org.chromium.Chromium'
	'/var/lib/flatpak/exports/bin/com.microsoft.Edge'
	'/var/lib/flatpak/exports/bin/org.gnome.Epiphany'
	'/var/lib/flatpak/exports/bin/org.mozilla.firefox'
	'/var/lib/flatpak/exports/bin/io.gitlab.librewolf-community'
	'/var/lib/flatpak/exports/bin/com.github.Eloston.UngoogledChromium'
)

#######################################################################################################################

function yadmsg() {
	local cmsg="$1"

	yad --title="$TITLE" \
		--image=emblem-warning \
		--image-on-top \
		--form \
		--width=500 \
		--height=100 \
		--fixed \
		--align=center \
		--text "$cmsg" \
		--button="$BUTTON_FECHAR" \
		--center \
		--on-top \
		--borders=20 \
		--window-icon="$WEBAPPS_PATH"/icons/webapp.svg
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f yadmsg

#######################################################################################################################

function sh_webapp_check_dirs {
	# Verifica se o diretórios de trabalho existem; se não, cria
	[[ -d "$HOME_FOLDER" ]] || mkdir -p "$HOME_FOLDER"
	[[ -d "$TMP_FOLDER" ]] || mkdir -p "$TMP_FOLDER"
	[[ -d "$HOME_LOCAL"/share/icons ]] || mkdir -p "$HOME_LOCAL"/share/icons
	[[ -d "$HOME_LOCAL"/share/applications ]] || mkdir -p "$HOME_LOCAL"/share/applications
	[[ -d "$HOME_LOCAL"/bin ]] || mkdir "$HOME_LOCAL"/bin
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_check_dirs

#######################################################################################################################

function sh_check_webapp_is_running() {
	local PID

	if PID=$(pidof webapp-manager-biglinux) && [[ -n "$PID" ]]; then
		#       notify-send -u critical --icon=big-store --app-name "$0" "$TITLE" "${Amsg[error_open]}" --expire-time=2000
		#       kdialog --title "$TITLE" --icon warning --msgbox "${Amsg[error_open]}"
		yad --title "$TITLE" \
			--image-on-top \
			--form \
			--fixed \
			--align=center \
			--on-top \
			--center \
			--image=webapp \
			--text "${Amsg[error_open]}\nPID: $PID" \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--button="OK":0
		exit 1
	fi
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_check_webapp_is_running

#######################################################################################################################

function sh_webapp_change_browser() {
	local old_browser="$1"
	local new_browser="$2"
	local DESKTOP_FILES
	local CHANGED=0
	local -i nDesktop_Files_Found

	mapfile -t DESKTOP_FILES < <(find "$HOME_LOCAL"/share/applications -iname '*-webapp-biglinux.desktop')
	nDesktop_Files_Found="${#DESKTOP_FILES[@]}"

	if ((nDesktop_Files_Found)); then
		sh_webapp_write_new_browser "$new_browser"
		echo "$new_browser" >"$HOME_FOLDER"/BROWSER
		return
	fi

	function ChromeToFirefox() {
		for w in "${DESKTOP_FILES[@]}"; do
			filename="${w##*/}"
			cp -f "$WEBAPPS_PATH"/assets/"$old_browser"/bin/"${filename%%.*}-$old_browser" "$HOME"/.local/bin
			cp -f "$WEBAPPS_PATH"/assets/"$old_browser"/desk/"$filename" "$HOME"/.local/share/applications
		done
	}

	function FirefoxToChrome() {
		for w in "${DESKTOP_FILES[@]}"; do
			cp -f "$WEBAPPS_PATH"/webapps/"${w##*/}" "$HOME"/.local/share/applications
		done
	}

	case "$old_browser" in
	firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
		case "$new_browser" in
		firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
			ChromeToFirefox "$new_browser"
			CHANGED=1
			;;

		*)
			FirefoxToChrome
			CHANGED=1
			;;
		esac
		;;

	*)
		case "$new_browser" in
		firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
			ChromeToFirefox "$new_browser"
			CHANGED=1
			;;

		*) : ;;
		esac
		;;
	esac

	if ((CHANGED)); then
		update-desktop-database -q "$HOME"/.local/share/applications
		nohup kbuildsycoca5 &>/dev/null &
	fi

	sh_webapp_write_new_browser "$new_browser"
	echo "$new_browser" >"$HOME_FOLDER"/BROWSER
	return
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_change_browser

#######################################################################################################################

function sh_webapp_check_browserOLD() {
	local default_browser= # Define o navegador padrão
	local NOT_COMPATIBLE=0 # Flag para indicar se navegador é compatível

	# Verifica a existência de navegadores instalados e define o navegador padrão
	if [ -e /usr/lib/brave-browser/brave ] || [ -e /opt/brave-bin/brave ]; then
		default_browser='brave'
	elif [ -e /opt/google/chrome/google-chrome ]; then
		default_browser='google-chrome-stable'
	elif [ -e /usr/lib/chromium/chromium ]; then
		default_browser='chromium'
	elif [ -e /opt/microsoft/msedge/microsoft-edge ]; then
		default_browser='microsoft-edge-stable'
	elif [ -e /usr/lib/firefox/firefox ]; then
		sh_webapp_change_browser 'brave' 'firefox'
	elif [ -e /usr/lib/librewolf/librewolf ]; then
		sh_webapp_change_browser 'brave' 'librewolf'
	elif [ -e /usr/bin/falkon ]; then
		default_browser='falkon'
	elif [ -e /opt/vivaldi/vivaldi ]; then
		default_browser='vivaldi-stable'

	elif [ -e /var/lib/flatpak/exports/bin/com.brave.Browser ]; then
		default_browser='com.brave.Browser'
	elif [ -e /var/lib/flatpak/exports/bin/com.google.Chrome ]; then
		default_browser='com.google.Chrome'
	elif [ -e /var/lib/flatpak/exports/bin/org.chromium.Chromium ]; then
		default_browser='org.chromium.Chromium'
	elif [ -e /var/lib/flatpak/exports/bin/com.github.Eloston.UngoogledChromium ]; then
		default_browser='com.github.Eloston.UngoogledChromium'
	elif [ -e /var/lib/flatpak/exports/bin/com.microsoft.Edge ]; then
		default_browser='com.microsoft.Edge'
	elif [ -e /var/lib/flatpak/exports/bin/org.gnome.Epiphany ]; then
		default_browser=
		NOT_COMPATIBLE=1
	elif [ -e /var/lib/flatpak/exports/bin/org.mozilla.firefox ]; then
		sh_webapp_change_browser 'brave' 'org.mozilla.firefox'
	elif [ -e /var/lib/flatpak/exports/bin/io.gitlab.librewolf-community ]; then
		sh_webapp_change_browser 'brave' 'io.gitlab.librewolf-community'
	fi

	if ((NOT_COMPATIBLE)); then
		# Exibe uma mensagem de erro se nenhum navegador compatível for encontrado
		yad --image=emblem-warning \
			--image-on-top \
			--form \
			--width=500 \
			--height=100 \
			--fixed \
			--align=center \
			--text="$(gettext $"Não existem navegadores compatíveis com WebApps instalados!")" \
			--button="$(gettext $"Fechar")" \
			--on-top \
			--center \
			--borders=20 \
			--title="$TITLE" \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg"
		exit 1
	fi

	# Atualiza a configuração do navegador se necessário
	[[ "$(<~/.bigwebapps/BROWSER)" = "brave-browser" ]] && default_browser='brave'

	# Salva o navegador padrão no arquivo de configuração
	echo "$default_browser" >"$HOME_FOLDER"/BROWSER
}

#######################################################################################################################

function sh_webapp_write_new_browser() {
	local new_browser="$1"
	local default_browser= # Define o navegador padrão
	local compatible=1     # Flag para indicar se navegador é compatível
	local cpath
	local id
	local icon
	local data_bin
	local title
	local browser
	local native
	local flatpak
	local nc=0

	for browser in "${aBrowserId[@]}"; do
		if [[ "$browser" = "$new_browser" ]]; then
			cpath="${aBrowserPath[nc]}"
			default_browser="${aBrowserId[nc]}"
			id="${aBrowserId[nc]}"
			icon="${aBrowserIcon[nc]}"
			data_bin="${aBrowserId[nc]}"
			title="${aBrowserTitle[nc]^^}"
			compatible="${aBrowserCompatible[nc]}"
			[[ "$cpath" =~ '/flatpak/' ]] && {
				flatpak=1
				native=0
			} || {
				flatpak=0
				native=1
			}
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "path" "$cpath"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "name" "$default_browser"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "id" "$id"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "icon" "$icon"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "data_bin" "$data_bin"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "title" "$title"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "compatible" "$compatible"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "native" "$native"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "flatpak" "$flatpak"
			break
		fi
		((++nc))
	done
}
export -f sh_webapp_write_new_browser

#######################################################################################################################
function sh_webapp_verify_browser() {
	local default_browser="$1"
	local browser

	for browser in "${aBrowserId[@]}"; do
		if [[ "$browser" = "$default_browser" ]]; then
			return 0
		fi
	done
	return 1
}
export -f sh_webapp_verify_browser

#######################################################################################################################

function sh_webapp_check_browser() {
	local default_browser # Define o navegador padrão
	local compatible      # Flag para indicar se navegador é compatível
	local cpath
	local nc=0

	for cpath in "${aBrowserPath[@]}"; do
		if [[ -e "$cpath" ]]; then
			default_browser="${aBrowserId[nc]}"
			compatible="${aBrowserCompatible[nc]}"
			# Atualiza a configuração do navegador
			sh_webapp_write_new_browser "$default_browser"
			break
		fi
		((++nc))
	done

	if ! ((compatible)); then
		# Exibe uma mensagem de erro se nenhum navegador compatível for encontrado
		yad --image=emblem-warning \
			--image-on-top \
			--form \
			--width=500 \
			--height=100 \
			--fixed \
			--align=center \
			--text="$(gettext $"Não existem navegadores compatíveis com WebApps instalados!")" \
			--button="$(gettext $"Fechar")" \
			--on-top \
			--center \
			--borders=20 \
			--title="$TITLE" \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg"
		exit 1
	fi
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_check_browser

#######################################################################################################################

function sh_webapp_change_icon() {
	local file_icon
	local new_file_icon
	local SUBTITLE="$(gettext $"Selecione o arquivo de imagem")"
	local cancel=1

	cd "$(xdg-user-dir PICTURES)"
	file_icon=$(
		yad --title "$SUBTITLE" \
			--file \
			--center \
			--width=900 \
			--height=600 \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--mime-filter=$"Arquivos de Imagem""|image/bmp image/jpeg image/png image/x-icon"
	)

	if [[ "$?" -eq "$cancel" ]] || [[ -z "$file_icon" ]]; then
		exit
	fi

	new_file_icon=$("$WEBAPPS_PATH"/resize_favicon.sh.py "$file_icon")
	printf "$new_file_icon"
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_change_icon

#######################################################################################################################

function sh_webapp_backup() {
	local SUBTITLE="$(gettext $"Não existem WebApps instalados para backup!")"
	local SAVE_DIR_TITLE="$(gettext $"Selecione o diretório para salvar:")"
	local backup_file="backup-webapps_$(date +%Y-%m-%d).tar.gz"
	local TMP_DIR="$TMP_FOLDER/backup-webapps"
	local TMP_DIR_BIN="$TMP_DIR/bin"
	local TMP_DIR_DATA="$TMP_DIR/data"
	local TMP_DIR_ICON="$TMP_DIR/icons"
	local TMP_DIR_EPIHANY="$TMP_DIR/epiphany"
	local TMP_DIR_PORTAL="$TMP_DIR_EPIHANY/xdg-desktop-portal"
	local TMP_DIR_EPIHANY_DATA="$TMP_DIR_EPIHANY/data"
	local TMP_DIR_DESKTOP="$TMP_DIR/desktop"
	local WEBAPPS
	local SAVE_DIR
	local DATA_FOLDER
	local DATA_FOLDER_COPY
	local DATA_DIR_COPY
	local TMP_FILE_ICON
	local TMP_FILE_BIN
	local -i nDesktop_Files_Found
	local -i cancel=1

	mapfile -t WEBAPPS < <(find "$HOME"/.local/share/applications -iname "*-webapp-biglinux-custom.desktop")
	nDesktop_Files_Found="${#WEBAPPS[@]}"

	if ! ((nDesktop_Files_Found)); then
		yad --title="$TITLE" \
			--image=emblem-warning \
			--image-on-top \
			--form \
			--width=500 \
			--height=100 \
			--fixed \
			--align=center \
			--text="$SUBTITLE" \
			--button="$BUTTON_CLOSE" \
			--on-top \
			--center \
			--borders=20 \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg"
		exit 1
	fi

	cd "$HOME_FOLDER" || return
	SAVE_DIR=$(
		yad --title="$SAVE_DIR_TITLE" \
			--file \
			--directory \
			--center \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--width=900 --height=600
	)

	if [[ "$?" -eq "$cancel" ]] || [[ -z "$SAVE_DIR" ]]; then
		exit
	fi

	for w in "${WEBAPPS[@]}"; do
		if grep -q '.local.bin' "$w"; then
			mkdir -p "$TMP_DIR_BIN"
			TMP_FILE_BIN=$(awk -F'=' '/^Exec/{print $2}' "$w")
			cp -a "$BIN" "$TMP_DIR_BIN"
			DATA_FOLDER=$(sed -n '/^FOLDER/s/.*=\([^\n]*\).*/\1/p' "$TMP_FILE_BIN")
			if grep -q '.bigwebapps' <<<"$DATA_FOLDER"; then
				mkdir -p "$TMP_DIR_DATA"
				cp -a "$DATA_FOLDER" "$TMP_DIR_DATA"
			else
				DATA_FOLDER_COPY="$TMP_DIR/flatpak/$(awk -F'/' '{print $6"/"$7}' <<<"$DATA_FOLDER")"
				mkdir -p "$DATA_FOLDER_COPY"
				cp -a "$DATA_FOLDER" "$DATA_FOLDER_COPY"
			fi
		fi

		if grep -q '..no.first.run' "$w"; then
			DATA_DIR=$(awk '/Exec/{sub(/--user-data-dir=/,"");print $2}' "$w")
			if grep -q '.bigwebapps' <<<"$DATA_DIR"; then
				mkdir -p "$TMP_DIR_DATA"
				cp -a "$DATA_DIR" "$TMP_DIR_DATA"
			else
				DATA_DIR_COPY="$TMP_DIR/flatpak/$(awk -F'/' '{print $6"/"$7}' <<<"$DATA_DIR")"
				mkdir -p "$DATA_DIR_COPY"
				cp -a "$DATA_DIR" "$DATA_DIR_COPY"
			fi
		fi

		if grep -q '..profile=' "$w"; then
			mkdir -p "$TMP_DIR_PORTAL"
			cp -a "$HOME"/.local/share/xdg-desktop-portal/* "$TMP_DIR_PORTAL"
			EPI_DATA=$(awk '/Exec/{sub(/--profile=/,"");print $3}' "$w")
			mkdir -p "$TMP_DIR_EPIHANY_DATA"
			cp -a "$EPI_DATA" "$TMP_DIR_EPIHANY_DATA"
		else
			mkdir -p "$TMP_DIR_ICON"
			TMP_FILE_ICON=$(awk -F'=' '/^Icon/{print $2}' "$w")
			cp -a "$ICON" "$TMP_DIR_ICON"
			cp -a "$w" "$TMP_DIR"
		fi

		if [ -L "$(xdg-user-dir DESKTOP)/${w##*/}" ]; then
			mkdir -p "$TMP_DIR_DESKTOP"
			cp -a "$(xdg-user-dir DESKTOP)/${w##*/}" "$TMP_DIR_DESKTOP"
		fi
	done

	cd "$TMP_FOLDER" || return
	tar -czf "${SAVE_DIR}/${backup_file}" backup-webapps
	rm -r backup-webapps
	echo "${SAVE_DIR}/${backup_file}"
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_backup

#######################################################################################################################

function sh_webapp_restore() {
	local SUBTITLE="$(gettext $"Selecionar o arquivo de backup para restaurar: ")"
	local BKP_FOLDER="$TMP_FOLDER/backup-webapps"
	local FLATPAK_FOLDER_DATA="$HOME"/.var/app
	local backup_file
	local cancel=1

	cd "$HOME_FOLDER" || return
	backup_file=$(
		yad --title="$SUBTITLE" \
			--file \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--width=900 \
			--height=600 \
			--center \
			--mime-filter=$"Backup WebApps""|application/gzip"
	)
	if [[ "$?" -eq "$cancel" ]] || [[ -z "$backup_file" ]]; then
		exit
	fi

	if tar -xzf "$backup_file" -C "$TMP_FOLDER"; then
		if [[ -d "$BKP_FOLDER" ]]; then
			cp -a "$BKP_FOLDER"/*.desktop "$HOME_LOCAL"/share/applications
			cp -a "$BKP_FOLDER"/icons/* "$HOME_LOCAL"/share/icons

			if [[ -d "$BKP_FOLDER"/bin ]]; then
				cp -a "$BKP_FOLDER"/bin/* "$HOME_LOCAL"/bin
			fi

			if [[ -d "$BKP_FOLDER"/data ]]; then
				cp -a "$BKP_FOLDER"/data/* "$HOME_FOLDER"
			fi

			if [[ -d "$BKP_FOLDER"/epiphany ]]; then
				cp -a "$BKP_FOLDER"/epiphany/data "$FLATPAK_FOLDER_DATA"/org.gnome.Epiphany
				cp -a "$BKP_FOLDER"/epiphany/xdg-desktop-portal "$HOME_LOCAL"/share
				ln -sf "$HOME"/.local/share/xdg-desktop-portal/applications/*.desktop "$HOME_LOCAL"/share/applications
			fi

			if [[ -d "$BKP_FOLDER"/flatpak ]]; then
				cp -a "$BKP_FOLDER"/flatpak/* "$FLATPAK_FOLDER_DATA"
			fi

			if [[ -d "$BKP_FOLDER"/desktop ]]; then
				cp -a "$BKP_FOLDER"/desktop/* "$(xdg-user-dir DESKTOP)"
			fi

			rm -r "$BKP_FOLDER"
			update-desktop-database -q "$HOME_LOCAL"/share/applications
			nohup kbuildsycoca5 &>/dev/null &

			printf 0
			exit
		fi
	fi
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_restore

#######################################################################################################################

function sh_webapp_enable_disable() {
	local LOCAL_DIR="$HOME_LOCAL/share/applications/$1"

	case "$2" in
	firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
		if [[ ! -e "$LOCAL_DIR" ]]; then
			cp "$WEBAPPS_PATH/assets/$2/desk/$1" "$HOME_LOCAL"/share/applications
			cp "$WEBAPPS_PATH/assets/$2/bin/${1%%.*}-$2" "$HOME_LOCAL"/bin
		else
			rm "$LOCAL_DIR"
		fi
		;;

	*)
		if [[ ! -e "$LOCAL_DIR" ]]; then
			cp "$WEBAPP_PATH/webapps/$1" "$HOME_LOCAL"/share/applications
		else
			rm "$LOCAL_DIR"
		fi
		;;
	esac

	update-desktop-database -q "$HOME_LOCAL"/share/applications
	nohup kbuildsycoca5 &>/dev/null &
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_enable_disable

#######################################################################################################################

function sh_webapp-edit() {
	CHANGE=false
	EDIT=false

	if [ "$browserOld" != "$browserNew" ]; then
		name_file="$RANDOM-${icondesk##*/}"
		cp -f "$icondesk" /tmp/"$name_file"
		icondesk=/tmp/"$name_file"
		CHANGE=true
	fi

	if [ "$newperfil" = "on" ]; then
		if ! grep -q '..user.data.dir.' "$filedesk"; then
			name_file="$RANDOM-${icondesk##*/}"
			cp -f "$icondesk" /tmp/"$name_file"
			icondesk=/tmp/"$name_file"
			CHANGE=true
		fi
	fi

	if [ "$CHANGE" = "true" ]; then
		JSON="{
  \"browser\"   : \"$browserNew\",
  \"category\"  : \"$category\",
  \"filedesk\"  : \"$filedesk\",
  \"icondesk\"  : \"$icondesk\",
  \"namedesk\"  : \"$namedesk\",
  \"newperfil\" : \"$newperfil\",
  \"shortcut\"  : \"$shortcut\",
  \"urldesk\"   : \"$urldesk\"
}"
		printf "%s" "$JSON"
		exit
	fi

	if [ "$icondesk" != "$icondeskOld" ]; then
		mv -f "$icondesk" "$icondeskOld"
		EDIT=true
	fi

	if [ "$namedeskOld" != "$namedesk" ]; then
		sed -i "s|Name=$namedeskOld|Name=$namedesk|" "$filedesk"
		EDIT=true
	fi

	if [ "$categoryOld" != "$category" ]; then
		sed -i "s|Categories=$categoryOld;|Categories=$category;|" "$filedesk"
		EDIT=true
	fi

	if [ ! "$newperfil" ]; then
		if grep -q '..user.data.dir.' "$filedesk"; then
			FIELD=$(awk '/Exec/{print $2}' "$filedesk")
			FOLDER=$(awk -F'=' '{print $2}' <<<"$FIELD")
			rm -r "$FOLDER"
			sed -i "s|$FIELD --no-first-run ||" "$filedesk"
			EDIT=true
		fi
	fi

	USER_DESKTOP=$(xdg-user-dir DESKTOP)
	DESKNAME=${filedesk##*/}
	if [ "$shortcut" = "on" ]; then
		if [ ! -L "$USER_DESKTOP/$DESKNAME" ]; then
			ln -sf "$filedesk" "$USER_DESKTOP/$DESKNAME"
			chmod 755 "$USER_DESKTOP/$DESKNAME"
			gio set "$USER_DESKTOP/$DESKNAME" -t string metadata::trust "true"
			EDIT=true
		else
			ln -sf "$filedesk" "$USER_DESKTOP/$DESKNAME"
			chmod 755 "$USER_DESKTOP/$DESKNAME"
			gio set "$USER_DESKTOP/$DESKNAME" -t string metadata::trust "true"
		fi
	else
		if [ -L "$USER_DESKTOP/$DESKNAME" ]; then
			unlink "$USER_DESKTOP/$DESKNAME"
			EDIT=true
		fi
	fi

	if [ "$EDIT" = "true" ]; then
		nohup update-desktop-database -q ~/.local/share/applications &
		nohup kbuildsycoca5 &>/dev/null &
		rm -f /tmp/*.png
		printf '{ "return" : "0" }'
		exit
	fi

	if [ "$EDIT" = "false" ] && [ "$CHANGE" = "false" ]; then
		printf '{ "return" : "1" }'
		exit
	fi
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-edit

#######################################################################################################################

function sh_webapp-launch() {
	local app="$1"
	local FILE="$HOME_LOCAL"/share/applications/"$app"
	local EXEC

	if grep -q '.local.bin' "$FILE"; then
		EXEC=~/$(sed -n '/^Exec/s/.*=~\/\([^\n]*\).*/\1/p' "$FILE")
		"${EXEC}"
	else
		gtk-launch "$app"
	fi
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-launch

#######################################################################################################################

function sh_webapp-remove-all() {
	mapfile -t WEBAPPS < <(find "$HOME_LOCAL"/share/applications -iname "*-webapp-biglinux-custom.desktop")

	for filedesk in "${WEBAPPS[@]}"; do
		ICONDESK=$(awk -F'=' '/Icon/{print $2}' "$filedesk")
		LINK=$(xdg-user-dir DESKTOP)/"${filedesk##*/}"

		#if grep -q '..no.first.run' "$filedesk";then
		#    DATA_DIR=$(awk '/Exec/{sub(/--user-data-dir=/,"");print $2}' "$filedesk")
		#    [ -d "$DATA_DIR" ] && rm -r "$DATA_DIR"
		#fi

		if grep -q '..profile=' "$filedesk"; then
			#EPI_DATA=$(awk '/Exec/{sub(/--profile=/,"");print $3}' "$filedesk")
			DIR_PORTAL_APP=~/.local/share/xdg-desktop-portal/applications
			DIR_PORTAL_FILEDESK="$DIR_PORTAL_APP/${filedesk##*/}"
			[ -e "$DIR_PORTAL_FILEDESK" ] && rm "$DIR_PORTAL_FILEDESK"
			#rm -r "$EPI_DATA"
		fi

		#if grep -q '.local.bin' "$filedesk";then
		#    DESKBIN=~/.local/bin/$(sed -n '/^Exec/s/.*\/\([^\/]*\)$/\1/p' "$filedesk")
		#    DATA_FOLDER=$(sed -n '/^FOLDER/s/.*=\([^\n]*\).*/\1/p' "$DESKBIN")
		#    rm "$DESKBIN"
		#    rm -r "$DATA_FOLDER"
		#fi

		if [ -L "$LINK" ] || [ -e "$LINK" ]; then
			unlink "$LINK"
		fi

		#if [ -n "$(grep 'falkon' "$filedesk")" ];then
		#    folder=$(awk '/Exec=/{print $3}' "$filedesk")
		#    rm -r ${HOME}/.config/falkon/profiles/${folder}
		#fi

		[ -e "$ICONDESK" ] && rm "$ICONDESK"
		rm "$filedesk"
	done

	nohup update-desktop-database -q ~/.local/share/applications &
	nohup kbuildsycoca5 &>/dev/null &
	printf 0
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-remove-all

#######################################################################################################################

function sh_webapp-remove() {
	ICONDESK=$(awk -F'=' '/Icon/{print $2}' "$filedesk")
	LINK=$(xdg-user-dir DESKTOP)/"${filedesk##*/}"

	#if grep -q '..no.first.run' "$filedesk";then
	#    DATA_DIR=$(awk '/Exec/{sub(/--user-data-dir=/,"");print $2}' "$filedesk")
	#    [ -d "$DATA_DIR" ] && rm -r "$DATA_DIR"
	#fi

	if grep -q '..profile=' "$filedesk"; then
		#EPI_DATA=$(awk '/Exec/{sub(/--profile=/,"");print $3}' "$filedesk")
		DIR_PORTAL_APP=~/.local/share/xdg-desktop-portal/applications
		DIR_PORTAL_FILEDESK="$DIR_PORTAL_APP/${filedesk##*/}"
		[ -e "$DIR_PORTAL_FILEDESK" ] && rm "$DIR_PORTAL_FILEDESK"
		#rm -r "$EPI_DATA"
	fi

	#if grep -q '.local.bin' "$filedesk";then
	#    DESKBIN=~/.local/bin/$(sed -n '/^Exec/s/.*\/\([^\/]*\)$/\1/p' "$filedesk")
	#    DATA_FOLDER=$(sed -n '/^FOLDER/s/.*=\([^\n]*\).*/\1/p' "$DESKBIN")
	#    rm "$DESKBIN"
	#    rm -r "$DATA_FOLDER"
	#fi

	if [ -L "$LINK" ] || [ -e "$LINK" ]; then
		unlink "$LINK"
	fi

	#if [ -n "$(grep 'falkon' "$filedesk")" ];then
	#    folder=$(awk '/Exec=/{print $3}' "$filedesk")
	#    rm -r ${HOME}/.config/falkon/profiles/${folder}
	#fi

	[ -e "$ICONDESK" ] && rm "$ICONDESK"
	rm "$filedesk"

	nohup update-desktop-database -q ~/.local/share/applications &
	nohup kbuildsycoca5 &>/dev/null &
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-remove

#######################################################################################################################

function sh_webapp-install() {
	_NAMEDESK=$(sed 's|https\:\/\/||;s|http\:\/\/||;s|www\.||;s|\/.*||;s|\.|-|g' <<<"$urldesk")
	USER_DESKTOP=$(xdg-user-dir DESKTOP)
	LINK_APP="$HOME_LOCAL/share/applications/$_NAMEDESK-$RANDOM-webapp-biglinux-custom.desktop"
	BASENAME_APP="${LINK_APP##*/}"
	NAME="${BASENAME_APP/-webapp-biglinux-custom.desktop/}"
	DIR_PROF="$HOME_FOLDER/$NAME"
	FILE_LINK="$USER_DESKTOP/$NAME-webapp-biglinux-custom.desktop"
	BASENAME_ICON="${icondesk##*/}"
	NAME_FILE="${BASENAME_ICON// /-}"
	ICON_FILE="$HOME_LOCAL"/share/icons/"$NAME_FILE"

	if grep -qiE 'firefox|librewolf' <<<"$browser"; then
		browser_name="$browser"

		if ! grep -qiE '^http:|^https:|^localhost|^127' <<<"$urldesk"; then
			urldesk="https://$urldesk"
		fi

		if [ "${icondesk##*/}" = "default-webapps.png" ]; then
			cp "$icondesk" "$ICON_FILE"
		else
			mv "$icondesk" "$ICON_FILE"
		fi

		if [ "$browser" = "org.mozilla.firefox" ]; then
			browser="/var/lib/flatpak/exports/bin/org.mozilla.firefox"
			DIR_PROF="$HOME/.var/app/org.mozilla.firefox/data/$NAME"
		elif [ "$browser" = "io.gitlab.librewolf-community" ]; then
			browser="/var/lib/flatpak/exports/bin/io.gitlab.librewolf-community"
			DIR_PROF="$HOME/.var/app/io.gitlab.librewolf-community/data/$NAME"
		fi

		DESKBIN="$HOME_LOCAL/bin/$NAME"
		cat >"$DESKBIN" <<-EOF
			#!/usr/bin/env bash

			FOLDER=$DIR_PROF
			CLASS="$browser_name-webapp-$_NAMEDESK"

			if [ ! -d "\$FOLDER" ];then
			    mkdir -p "\$FOLDER/chrome"
			    cp -a /usr/share/bigbashview/bcc/apps/biglinux-webapps/profile/userChrome.css "\$FOLDER/chrome"
			    cp -a /usr/share/bigbashview/bcc/apps/biglinux-webapps/profile/user.js "\$FOLDER"
			fi

			MOZ_DISABLE_GMP_SANDBOX=1 MOZ_DISABLE_CONTENT_SANDBOX=1 \\
			XAPP_FORCE_GTKWINDOW_ICON=$ICON_FILE \\
			$browser --class="\$CLASS" --profile "\$FOLDER" --no-remote --new-instance "$urldesk" &
		EOF
		chmod +x "$DESKBIN"

		cat >"$LINK_APP" <<-EOF
			[Desktop Entry]
			Version=1.0
			Terminal=false
			Type=Application
			Name=$namedesk
			Exec=$DESKBIN
			Icon=$ICON_FILE
			Categories=$category;
			X-KDE-StartupNotify=true
		EOF
		chmod +x "$LINK_APP"

		if [ "$shortcut" = "on" ]; then
			ln -s "$LINK_APP" "$FILE_LINK"
			chmod 755 "$FILE_LINK"
			gio set "$FILE_LINK" -t string metadata::trust "true"
		fi

	elif grep -q 'org.gnome.Epiphany' <<<"$browser"; then
		if ! grep -Eq '^http:|^https:|^localhost|^127' <<<"$urldesk"; then
			urldesk="https://$urldesk"
		fi

		DIR_PORTAL="$HOME/.local/share/xdg-desktop-portal"
		DIR_PORTAL_APP="$DIR_PORTAL/applications"
		DIR_PORTAL_ICON="$DIR_PORTAL/icons/64x64"

		mkdir -p "$DIR_PORTAL_APP"
		mkdir -p "$DIR_PORTAL_ICON"

		FOLDER_DATA="$HOME/.var/app/org.gnome.Epiphany/data/org.gnome.Epiphany.WebApp_$NAME-webapp-biglinux-custom"
		browser="/var/lib/flatpak/exports/bin/org.gnome.Epiphany"
		EPI_FILEDESK="org.gnome.Epiphany.WebApp_$NAME-webapp-biglinux-custom.desktop"
		EPI_DIR_FILEDESK="$DIR_PORTAL_APP/$EPI_FILEDESK"
		EPI_FILE_ICON="$DIR_PORTAL_ICON/${EPI_FILEDESK/.desktop/}.png"

		EPI_LINK="$HOME/.local/share/applications/$EPI_FILEDESK"
		EPI_DESKTOP_LINK="$USER_DESKTOP/$EPI_FILEDESK"
		mkdir -p "$FOLDER_DATA"
		true >"$FOLDER_DATA/.app"
		echo -n 37 >"$FOLDER_DATA/.migrated"

		if [ "${icondesk##*/}" = "default-webapps.png" ]; then
			cp "$icondesk" "$EPI_FILE_ICON"
		else
			mv "$icondesk" "$EPI_FILE_ICON"
		fi

		cat >"$EPI_DIR_FILEDESK" <<-EOF
			[Desktop Entry]
			Name=$namedesk
			Exec=$browser --application-mode --profile=$FOLDER_DATA $urldesk
			StartupNotify=true
			Terminal=false
			Type=Application
			Categories=$category;
			Icon=$EPI_FILE_ICON
			StartupWMClass=$namedesk
			X-Purism-FormFactor=Workstation;Mobile;
			X-Flatpak=org.gnome.Epiphany
		EOF

		chmod +x "$EPI_DIR_FILEDESK"
		ln -s "$EPI_DIR_FILEDESK" "$EPI_LINK"

		if [ "$shortcut" = "on" ]; then
			ln -s "$EPI_DIR_FILEDESK" "$EPI_DESKTOP_LINK"
			chmod 755 "$EPI_DESKTOP_LINK"
			gio set "$EPI_DESKTOP_LINK" -t string metadata::trust "true"
		fi

	elif grep -q 'falkon' <<<"$browser"; then
		if ! grep -Eq '^http:|^https:|^localhost|^127' <<<"$urldesk"; then
			urldesk="https://$urldesk"
		fi

		if [ "$newperfil" = "on" ]; then
			mkdir -p $HOME/.config/falkon/profiles/$NAME
			browser="$browser -p $NAME -ro"
		else
			browser="$browser -ro"
		fi

		if [ "${icondesk##*/}" = "default-webapps.png" ]; then
			cp "$icondesk" "$ICON_FILE"
		else
			mv "$icondesk" "$ICON_FILE"
		fi

		cat >"$LINK_APP" <<-EOF
			[Desktop Entry]
			Version=1.0
			Terminal=false
			Type=Application
			Name=$namedesk
			Exec=$browser $urldesk
			Icon=$ICON_FILE
			Categories=$category;
		EOF
		chmod +x "$LINK_APP"

		if [ "$shortcut" = "on" ]; then
			ln -s "$LINK_APP" "$FILE_LINK"
			chmod 755 "$FILE_LINK"
			gio set "$FILE_LINK" -t string metadata::trust "true"
		fi

	else
		case $browser in
		com.brave.Browser)
			browser="/var/lib/flatpak/exports/bin/com.brave.Browser"
			DIR_PROF="$HOME/.var/app/com.brave.Browser/data/$NAME"
			;;

		com.google.Chrome)
			browser="/var/lib/flatpak/exports/bin/com.google.Chrome"
			DIR_PROF="$HOME/.var/app/com.google.Chrome/data/$NAME"
			;;

		com.microsoft.Edge)
			browser="/var/lib/flatpak/exports/bin/com.microsoft.Edge"
			DIR_PROF="$HOME/.var/app/com.microsoft.Edge/data/$NAME"
			;;

		org.chromium.Chromium)
			browser="/var/lib/flatpak/exports/bin/org.chromium.Chromium"
			DIR_PROF="$HOME/.var/app/org.chromium.Chromium/data/$NAME"
			;;

		com.github.Eloston.UngoogledChromium)
			browser="/var/lib/flatpak/exports/bin/com.github.Eloston.UngoogledChromium"
			DIR_PROF="$HOME/.var/app/com.github.Eloston.UngoogledChromium/data/$NAME"
			;;
		esac

		if ! grep -Eq '^http:|^https:|^localhost|^127' <<<"$urldesk"; then
			urldesk="https://$urldesk"
		fi

		if [ "$newperfil" = "on" ]; then
			browser="$browser --user-data-dir=$DIR_PROF --no-first-run"
		fi

		if [ "${icondesk##*/}" = "default-webapps.png" ]; then
			cp "$icondesk" "$ICON_FILE"
		else
			mv "$icondesk" "$ICON_FILE"
		fi

		CUT_HTTP=$(sed 's|https://||;s|/|_|g;s|_|__|1;s|_$||;s|_$||;s|&|_|g;s|?||g;s|=|_|g' <<<"$urldesk")

		cat >"$LINK_APP" <<-EOF
			[Desktop Entry]
			Version=1.0
			Terminal=false
			Type=Application
			Name=$namedesk
			Exec=$browser --class=$CUT_HTTP,Chromium-browser --profile-directory=Default --app=$urldesk
			Icon=$ICON_FILE
			Categories=$category;
			StartupWMClass=$CUT_HTTP
		EOF
		chmod +x "$LINK_APP"

		if [ "$shortcut" = "on" ]; then
			ln -s "$LINK_APP" "$FILE_LINK"
			chmod 755 "$FILE_LINK"
			gio set "$FILE_LINK" -t string metadata::trust "true"
		fi
	fi

	nohup update-desktop-database -q ~/.local/share/applications &
	nohup kbuildsycoca5 &>/dev/null &

	rm -f /tmp/*.png
	rm -rf /tmp/.bigwebicons
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-install

#######################################################################################################################

function sh_webapp-info() {
	DESKNAME=${filedesk##*/}
	USER_DESKTOP=$(xdg-user-dir DESKTOP)
	NAME=$(awk -F'=' '/Name/{print $2}' "$filedesk")
	ICON=$(awk -F'=' '/Icon/{print $2}' "$filedesk")
	CATEGORY=$(awk -F'=' '/Categories/{print $2}' "$filedesk")
	EXEC=$(awk '/Exec/{print $0}' "$filedesk")

	if grep -q '.local.bin' <<<"$EXEC"; then
		BIN=$(awk -F'=' '{print $2}' <<<"$EXEC")
		URL=$(awk '/new-instance/{gsub(/"/, "");print $7}' "$BIN")
		BROWSER=$(awk '/new-instance/{print $1}' "$BIN")
	elif grep -q 'falkon' <<<"$EXEC"; then
		URL=$(awk '{print $NF}' <<<"$EXEC")
		BROWSER=$(awk '{gsub(/Exec=/, "");print $1}' <<<"$EXEC")
	else
		URL=$(awk -F'app=' '{print $2}' <<<"$EXEC")
		BROWSER=$(awk '{gsub(/Exec=/, "");print $1}' <<<"$EXEC")
		if [ ! "$URL" ]; then
			URL=$(awk '{print $4}' <<<"$EXEC")
		fi
	fi

	if grep -q '.var.lib.flatpak.exports.bin' <<<"$BROWSER"; then
		BROWSER=${BROWSER##*/}
	fi

	if grep -q '..user.data.dir.' <<<"$EXEC"; then
		checked_perfil='checked'
	elif grep -q 'falkon..p' <<<"$EXEC"; then
		checked_perfil='checked'
	fi

	[ -L "$USER_DESKTOP/$DESKNAME" ] && checked='checked'

	case "$BROWSER" in
	brave)
		_ICON='brave'
		selected_brave='selected'
		;;
	com.brave.Browser)
		_ICON='brave'
		selected_brave_flatpak='selected'
		;;
	google-chrome-stable)
		_ICON='chrome'
		selected_chrome='selected'
		;;
	com.google.Chrome)
		_ICON='chrome'
		selected_chrome_flatpak='selected'
		;;
	chromium)
		_ICON='chromium'
		selected_chromium='selected'
		;;
	org.chromium.Chromium)
		_ICON='chromium'
		selected_chromium_flatpak='selected'
		;;
	com.github.Eloston.UngoogledChromium)
		_ICON='ungoogled'
		selected_ungoogled_flatpak='selected'
		;;
	microsoft-edge-stable)
		_ICON='edge'
		selected_edge='selected'
		;;
	com.microsoft.Edge)
		_ICON='edge'
		selected_edge_flatpak='selected'
		;;
	org.gnome.Epiphany)
		_ICON='epiphany'
		selected_epiphany_flatpak='selected'
		;;
	firefox)
		_ICON='firefox'
		selected_firefox='selected'
		;;
	org.mozilla.firefox)
		_ICON='firefox'
		selected_firefox_flatpak='selected'
		;;
	librewolf)
		_ICON='librewolf'
		selected_librewolf='selected'
		;;
	io.gitlab.librewolf-community)
		_ICON='librewolf'
		selected_librewolf_flatpak='selected'
		;;
	vivaldi-stable)
		_ICON='vivaldi'
		selected_vivaldi='selected'
		;;
	falkon)
		_ICON='falkon'
		selected_falkon='selected'
		;;
	*) : ;;
	esac

	case "${CATEGORY/;/}" in
	Development)
		selected_Development='selected'
		;;
	Office)
		selected_Office='selected'
		;;
	Graphics)
		selected_Graphics='selected'
		;;
	Network)
		selected_Network='selected'
		;;
	Game)
		selected_Game='selected'
		;;
	AudioVideo)
		selected_AudioVideo='selected'
		;;
	Webapps)
		selected_Webapps='selected'
		;;
	Google)
		selected_Google='selected'
		;;
	*) : ;;
	esac

	echo -n '
<div class="content-section">
  <ul style="margin-top:-20px">
    <li>
      <div class="products">
        <svg viewBox="0 0 512 512">
          <path fill="currentColor" d="M512 256C512 397.4 397.4 512 256 512C114.6 512 0 397.4 0 256C0 114.6 114.6 0 256 0C397.4 0 512 114.6 512 256zM57.71 192.1L67.07 209.4C75.36 223.9 88.99 234.6 105.1 239.2L162.1 255.7C180.2 260.6 192 276.3 192 294.2V334.1C192 345.1 198.2 355.1 208 359.1C217.8 364.9 224 374.9 224 385.9V424.9C224 440.5 238.9 451.7 253.9 447.4C270.1 442.8 282.5 429.1 286.6 413.7L289.4 402.5C293.6 385.6 304.6 371.1 319.7 362.4L327.8 357.8C342.8 349.3 352 333.4 352 316.1V307.9C352 295.1 346.9 282.9 337.9 273.9L334.1 270.1C325.1 261.1 312.8 255.1 300.1 255.1H256.1C245.9 255.1 234.9 253.1 225.2 247.6L190.7 227.8C186.4 225.4 183.1 221.4 181.6 216.7C178.4 207.1 182.7 196.7 191.7 192.1L197.7 189.2C204.3 185.9 211.9 185.3 218.1 187.7L242.2 195.4C250.3 198.1 259.3 195 264.1 187.9C268.8 180.8 268.3 171.5 262.9 165L249.3 148.8C239.3 136.8 239.4 119.3 249.6 107.5L265.3 89.12C274.1 78.85 275.5 64.16 268.8 52.42L266.4 48.26C262.1 48.09 259.5 48 256 48C163.1 48 84.4 108.9 57.71 192.1L57.71 192.1zM437.6 154.5L412 164.8C396.3 171.1 388.2 188.5 393.5 204.6L410.4 255.3C413.9 265.7 422.4 273.6 433 276.3L462.2 283.5C463.4 274.5 464 265.3 464 256C464 219.2 454.4 184.6 437.6 154.5H437.6z"/>
        </svg>
        '$"URL:"'
      </div>
      <input type="search" class="input" id="urlDeskEdit" name="urldesk" value="'$URL'" readonly/>
      <div class="button-wrapper">
        <div class=app-card>
          <div class="button-wrapper">
            <button class="button" style="height:30px" id="detectAllEdit">'$"Detectar Nome e Ícone"'</button>
          </div>
        </div>
      </div>
    </li>

    <li>
      <div class="products">
        <svg viewBox="0 0 512 512">
          <path fill="currentColor" d="M96 0C113.7 0 128 14.33 128 32V64H480C497.7 64 512 78.33 512 96C512 113.7 497.7 128 480 128H128V480C128 497.7 113.7 512 96 512C78.33 512 64 497.7 64 480V128H32C14.33 128 0 113.7 0 96C0 78.33 14.33 64 32 64H64V32C64 14.33 78.33 0 96 0zM448 160C465.7 160 480 174.3 480 192V352C480 369.7 465.7 384 448 384H192C174.3 384 160 369.7 160 352V192C160 174.3 174.3 160 192 160H448z"/>
        </svg>
        '$"Nome:"'
      </div>
      <input type="search" class="input" id="nameDeskEdit" name="namedesk" value="'$NAME'"/>
    </li>

    <li>
      <div class="products">
        <div style="margin-bottom:15px" class="svg-center">
          <div class="iconDetect-display-Edit">
            <div class="iconDetect-remove-Edit">
              <svg viewBox="0 0 448 512" style="width:20px;height:20px;"><path d="M384 32C419.3 32 448 60.65 448 96V416C448 451.3 419.3 480 384 480H64C28.65 480 0 451.3 0 416V96C0 60.65 28.65 32 64 32H384zM143 208.1L190.1 255.1L143 303C133.7 312.4 133.7 327.6 143 336.1C152.4 346.3 167.6 346.3 176.1 336.1L223.1 289.9L271 336.1C280.4 346.3 295.6 346.3 304.1 336.1C314.3 327.6 314.3 312.4 304.1 303L257.9 255.1L304.1 208.1C314.3 199.6 314.3 184.4 304.1 175C295.6 165.7 280.4 165.7 271 175L223.1 222.1L176.1 175C167.6 165.7 152.4 165.7 143 175C133.7 184.4 133.7 199.6 143 208.1V208.1z"/></svg>
            </div>
          </div>
          <img id="iconDeskEdit" src="'$ICON'" width="58" height="58" />
          <input type="hidden" name="icondesk" value="'$ICON'" id="inputIconDeskEdit" />
        </div>
        '$"Ícone do WebApp"'
      </div>
      <div class="button-wrapper">
        <button class="button" style="height:30px" id="loadIconEdit">'$"Alterar"'</button>
      </div>
    </li>

    <li>
      <div class="products">
        <div class="svg-center" id="thumb">
          <img height="58" width="58" id="browserEdit" src="'icons/$_ICON.svg'"/>
        </div>
        '$"Navegador"'
      </div>
      <div class="button-wrapper">
        <select class="svg-center" id="browserSelectEdit" name="browserNew">
          <option '$selected_brave' value="brave">'$"BRAVE"'</option>
          <option '$selected_chrome' value="google-chrome-stable">'$"CHROME"'</option>
          <option '$selected_chromium' value="chromium">'$"CHROMIUM"'</option>
          <option '$selected_edge' value="microsoft-edge-stable">'$"EDGE"'</option>
          <option '$selected_firefox' value="firefox">'$"FIREFOX"'</option>
          <option '$selected_librewolf' value="librewolf">'$"LIBREWOLF"'</option>
          <option '$selected_vivaldi' value="vivaldi-stable">'$"VIVALDI"'</option>
          <option '$selected_falkon' value="falkon">'$"FALKON"'</option>
          <option '$selected_brave_flatpak' value="com.brave.Browser">'$"BRAVE (FLATPAK)"'</option>
          <option '$selected_chrome_flatpak' value="com.google.Chrome">'$"CHROME (FLATPAK)"'</option>
          <option '$selected_chromium_flatpak' value="org.chromium.Chromium">'$"CHROMIUM (FLATPAK)"'</option>
          <option '$selected_ungoogled_flatpak' value="com.github.Eloston.UngoogledChromium">'$"UNGOOGLED (FLATPAK)"'</option>
          <option '$selected_edge_flatpak' value="com.microsoft.Edge">'$"EDGE (FLATPAK)"'</option>
          <option '$selected_epiphany_flatpak' value="org.gnome.Epiphany">'$"EPIPHANY (FLATPAK)"'</option>
          <option '$selected_firefox_flatpak' value="org.mozilla.firefox">'$"FIREFOX (FLATPAK)"'</option>
          <option '$selected_librewolf_flatpak' value="io.gitlab.librewolf-community">'$"LIBREWOLF (FLATPAK)"'</option>
        </select>
        <input type="hidden" name="browserOld" value="'$BROWSER'"/>
        <input type="hidden" name="filedesk" value="'$filedesk'"/>
        <input type="hidden" name="categoryOld" value="'${CATEGORY/;/}'"/>
        <input type="hidden" name="namedeskOld" value="'$NAME'"/>
        <input type="hidden" name="icondeskOld" value="'$ICON'"/>
      </div>
    </li>

    <li>
      <div class="products">
        <div class="svg-center" id="imgCategoryEdit">'"$(<./icons/${CATEGORY/;/}.svg)"'</div>
        '$"Categoria"'
      </div>
      <div class="button-wrapper">
        <div class="svg-center">
          <select class="svg-center" id="categorySelectEdit" name="category">
            <option value="Development" '$selected_Development' >'$"DESENVOLVIMENTO"'</option>
            <option value="Office" '$selected_Office' >'$"ESCRITÓRIO"'</option>
            <option value="Graphics" '$selected_Graphics' >'$"GRÁFICOS"'</option>
            <option value="Network" '$selected_Network' >INTERNET</option>
            <option value="Game" '$selected_Game' >'$"JOGOS"'</option>
            <option value="AudioVideo" '$selected_AudioVideo' >'$"MULTIMÍDIA"'</option>
            <option value="Webapps" '$selected_Webapps' >'$"WEBAPPS"'</option>
            <option value="Google" '$selected_Google' >'$"WEBAPPS GOOGLE"'</option>
          </select>
        </div>
      </div>
    </li>

    <li>
      <div class="products">
        <svg viewBox="0 0 512 512">
          <path fill="currentColor" d="M464 96h-192l-64-64h-160C21.5 32 0 53.5 0 80v352C0 458.5 21.5 480 48 480h416c26.5 0 48-21.5 48-48v-288C512 117.5 490.5 96 464 96zM336 311.1h-56v56C279.1 381.3 269.3 392 256 392c-13.27 0-23.1-10.74-23.1-23.1V311.1H175.1C162.7 311.1 152 301.3 152 288c0-13.26 10.74-23.1 23.1-23.1h56V207.1C232 194.7 242.7 184 256 184s23.1 10.74 23.1 23.1V264h56C349.3 264 360 274.7 360 288S349.3 311.1 336 311.1z"/>
        </svg>
        '$"Criar atalho na Área de Trabalho"'
      </div>
      <div class="button-wrapper">
        <input id="shortcut" type="checkbox" class="switch" name="shortcut" '$checked'/>
      </div>
    </li>

    <li>
      <div class="products">
        <svg viewBox="0 0 640 512">
          <path fill="currentColor" d="M224 256c70.7 0 128-57.31 128-128S294.7 0 224 0C153.3 0 96 57.31 96 128S153.3 256 224 256zM274.7 304H173.3C77.61 304 0 381.6 0 477.3C0 496.5 15.52 512 34.66 512h378.7C432.5 512 448 496.5 448 477.3C448 381.6 370.4 304 274.7 304zM616 200h-48v-48C568 138.8 557.3 128 544 128s-24 10.75-24 24v48h-48C458.8 200 448 210.8 448 224s10.75 24 24 24h48v48C520 309.3 530.8 320 544 320s24-10.75 24-24v-48h48C629.3 248 640 237.3 640 224S629.3 200 616 200z"/>
        </svg>
        '$"Perfil adicional"'
      </div>
      <div class="button-wrapper">
        <input id="addPerfilEdit" type="checkbox" class="switch" name="newperfil" '$checked_perfil'/>
      </div>
    </li>
  </ul>
</div>
<!--DETECT ICON MODAL-->
<div class="pop-up" id="detectIconEdit">
  <div class="pop-up__title">'$"Selecione o ícone preferido:"'
    <svg class="close" width="24" height="24" fill="none"
         stroke="currentColor" stroke-width="2"
         stroke-linecap="round" stroke-linejoin="round"
         class="feather feather-x-circle">
      <circle cx="12" cy="12" r="10" />
      <path d="M15 9l-6 6M9 9l6 6" />
    </svg>
  </div>
  <div id="desc">
    <div id="menu-icon"></div>
  </div>
</div>

<div class="pop-up" id="nameError">
  <div class="pop-up__subtitle">'$"Não é possível aplicar a edição sem Nome!"'</div>
  <div class="content-button-wrapper">
    <button class="content-button status-button2 close">'$"Fechar"'</button>
  </div>
</div>

<div class="pop-up" id="editError">
  <div class="pop-up__subtitle">'$"Não é possível aplicar a edição sem alterações!"'</div>
  <div class="content-button-wrapper">
    <button class="content-button status-button2 close">'$"Fechar"'</button>
  </div>
</div>

<div class="pop-up" id="editSuccess">
  <div class="pop-up__subtitle">'$"O WebApp foi editado com sucesso!"'</div>
  <div class="content-button-wrapper">
    <button class="content-button status-button2 close">'$"Fechar"'</button>
  </div>
</div>

<script type="text/javascript">

$("select").each(function(i, s){
  let getOptions = $(s).find("option");
  getOptions.sort(function(a, b) {
    return $(a).text() > $(b).text() ? 1 : -1;
  });
  $(this).html(getOptions);
});

$(function(){
  $(".pop-up#detectIconEdit .close").click(function(e){
    e.preventDefault();
    $(".pop-up#detectIconEdit").removeClass("visible");
  });

  $(".pop-up#nameError .close").click(function(e){
    e.preventDefault();
    $(".pop-up#nameError").removeClass("visible");
  });

  $(".pop-up#editError .close").click(function(e){
    e.preventDefault();
    $(".pop-up#editError").removeClass("visible");
  });

  $(".pop-up#editSuccess .close").click(function(e){
    e.preventDefault();
    $(".pop-up#editSuccess").removeClass("visible");
    document.location.reload(true);
  });

  $("#nameDeskEdit").css("border-bottom-color", "forestgreen");
  $("#nameDeskEdit").on("keyup paste search", function(){
    let checkName = $(this).val();
    if (!checkName){
      $(this).css("border-bottom-color", "");
    } else {
      $(this).css("border-bottom-color", "forestgreen");
    }
  })

  $("#loadIconEdit").click(function(e){
    e.preventDefault();
    fetch(`/execute$./change_icon.sh`)
    .then(resp => resp.text())
    .then(data => {
      if (data){
        $("#iconDeskEdit").attr("src", data);
        $("#inputIconDeskEdit").val(data);
        console.log("Change-Icon-Edit: "+data);
      } else {
        console.log("Change-Icon-Edit-Cancelled!");
      }
    });
  });

  var boxcheck = $("#addPerfilEdit").is(":checked");
  $("#browserSelectEdit").on("change", function(){
    switch (this.value){
      case "brave":
      case "com.brave.Browser":
        $("#browserEdit").attr("src", "icons/brave.svg");
        $("#addPerfilEdit").removeClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", true);
        }
        break;

      case "google-chrome-stable":
      case "com.google.Chrome":
        $("#browserEdit").attr("src", "icons/chrome.svg");
        $("#addPerfilEdit").removeClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", true);
        }
        break;

      case "chromium":
      case "org.chromium.Chromium":
        $("#browserEdit").attr("src", "icons/chromium.svg");
        $("#addPerfilEdit").removeClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", true);
        }
        break;

      case "com.github.Eloston.UngoogledChromium":
        $("#perfilAdd").removeClass('disabled');
        $("#browser").attr("src", "icons/ungoogled.svg");
        break;

      case "microsoft-edge-stable":
      case "com.microsoft.Edge":
        $("#browserEdit").attr("src", "icons/edge.svg");
        $("#addPerfilEdit").removeClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", true);
        }
        break;

      case "org.gnome.Epiphany":
        $("#browserEdit").attr("src", "icons/epiphany.svg");
        $("#addPerfilEdit").addClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", false);
        }
        break;

      case "firefox":
      case "org.mozilla.firefox":
        $("#browserEdit").attr("src", "icons/firefox.svg");
        $("#addPerfilEdit").addClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", false);
        }
        break;

      case "librewolf":
      case "io.gitlab.librewolf-community":
        $("#browserEdit").attr("src", "icons/librewolf.svg");
        $("#addPerfilEdit").addClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", false);
        }
        break;

      case "vivaldi-stable":
        $("#browserEdit").attr("src", "icons/vivaldi.svg");
        $("#addPerfilEdit").removeClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", true);
        }
        break;

      case "falkon":
        $("#browserEdit").attr("src", "icons/falkon.svg");
        $("#addPerfilEdit").removeClass("disabled");
        if (boxcheck) {
            $("#addPerfilEdit").prop("checked", true);
        }
        break;

      default:
          break;
    }
    console.log("Bowser-Combobox-Edit: "+this.value);
  });

  $("select#categorySelectEdit").change(function(){
    $("#imgCategoryEdit").load("icons/" + this.value + ".svg");
    console.log("Category-Edit: "+this.value)
  });

  $(".iconDetect-display-Edit").mouseover(function(){
    let srcIcon = $("#iconDeskEdit").attr("src");
    if (srcIcon !== "icons/default-webapp.svg"){
      $(".iconDetect-remove-Edit").show();
    }
  }).mouseleave(function(){
    $(".iconDetect-remove-Edit").hide();
  });

  $(".iconDetect-remove-Edit").click(function(e){
    e.preventDefault();
    $(".iconDetect-remove-Edit").hide();
    $("#iconDeskEdit").attr("src", "icons/default-webapp.svg");
    $.get("/execute$echo -n $PWD", function(cwd){
      $("#inputIconDeskEdit").val(cwd+"/icons/default-webapps.png");
      console.log("Default-Icon: "+$("#inputIconDeskEdit").val());
    });
  });

  $("#detectAllEdit").click(function(e){
    e.preventDefault();

    let url = $("#urlDeskEdit").val();
    $(".lds-ring").css("display", "inline-flex");

    fetch(`/execute$./get_title.sh.py ${url}`)
    .then(resp => resp.text())
    .then(data => {
      if (data){
        $("#nameDeskEdit").val(data);
        $("#nameDeskEdit").keyup();
      }
    });

    fetch(`/execute$./get_favicon.sh.py ${url}`)
    .then(resp => resp.text())
    .then(data => {
      if (data){
        if (/button/.test(data)){
          console.log("Multiple-Favicon");
          $(".pop-up#detectIconEdit #menu-icon").html(data)
          $(".lds-ring").css("display", "none");
          $(".pop-up#detectIconEdit").addClass("visible");
          $(".btn-img-favicon").each(function(index, el){
            $(el).click(function(e){
              e.preventDefault();
              let srcFav = $("#btn-icon-" + index + " img").attr("src");
              fetch(`/execute$./resize_favicon.sh.py ${srcFav}`)
              .then(resp => resp.text())
              .then(data => {
                $("#iconDeskEdit").attr("src", data);
                $("#inputIconDeskEdit").val(data);
                $(".pop-up#detectIconEdit").removeClass("visible");
              });
            });
          });
        } else {
          console.log("Single-Favicon");
          $("#iconDeskEdit").attr("src", data);
          $("#inputIconDeskEdit").val(data);
          $(".lds-ring").css("display", "none");
        }
      }
    });
  });

  var optionSelected = $("#browserSelectEdit").val();
  switch (optionSelected){
    case "firefox":
    case "librewolf":
    case "org.gnome.Epiphany":
    case "org.mozilla.firefox":
    case "io.gitlab.librewolf-community":
      console.log(optionSelected);
      $("#addPerfilEdit").addClass("disabled");
      break;

    default:
      break;
  }

});
</script>
'
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-info

#######################################################################################################################
