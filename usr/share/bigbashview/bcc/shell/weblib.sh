#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2094
#shellcheck source=/dev/null

#  weblib.sh
#  Description: Library for BigLinux WebApps
#
#  Created: 2024/05/31
#  Altered: 2024/06/01
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
_VERSION_="1.0.0-20240601"
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
)

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
export -f yadmsg

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

function sh_webapp_change_browser() {
	local DESKTOP_FILES
	local CHANGED=0
	local -i nDesktop_Files_Found

	mapfile -t DESKTOP_FILES < <(find "$HOME"/.local/share/applications -iname '*-webapp-biglinux.desktop')
	nDesktop_Files_Found="${#DESKTOP_FILES[@]}"

	if ((nDesktop_Files_Found)); then
		echo "$2" >"$HOME_FOLDER"/BROWSER
		return
	fi

	function ChromeToFirefox() {
		for w in "${DESKTOP_FILES[@]}"; do
			filename="${w##*/}"
			cp -f "$WEBAPPS_PATH"/assets/"$1"/bin/"${filename%%.*}-$1" "$HOME"/.local/bin
			cp -f "$WEBAPPS_PATH"/assets/"$1"/desk/"$filename" "$HOME"/.local/share/applications
		done
	}

	function FirefoxToChrome() {
		for w in "${DESKTOP_FILES[@]}"; do
			cp -f "$WEBAPPS_PATH"/webapps/"${w##*/}" "$HOME"/.local/share/applications
		done
	}

	case "$1" in
	firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
		case "$2" in
		firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
			ChromeToFirefox "$2"
			CHANGED=1
			;;

		*)
			FirefoxToChrome
			CHANGED=1
			;;
		esac
		;;

	*)
		case "$2" in
		firefox | org.mozilla.firefox | librewolf | io.gitlab.librewolf-community)
			ChromeToFirefox "$2"
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
	echo "$2" >"$HOME_FOLDER"/BROWSER
	return
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_change_browser

function sh_webapp_check_browser() {
	local default_browser= # Define o navegador padrão como 'brave'
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

# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_check_browser
