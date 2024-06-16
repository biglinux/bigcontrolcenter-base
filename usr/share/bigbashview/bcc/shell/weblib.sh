#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2094
#shellcheck source=/dev/null

#  weblib.sh
#  Description: Library for BigLinux WebApps
#
#  Created: 2024/05/31
#  Altered: 2024/06/16
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
_VERSION_="1.0.0-20240616"
#
export BOOTLOG="/tmp/bigwebapps-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
export HOME_FOLDER="$HOME/.bigwebapps"
export HOME_LOCAL="$HOME/.local"
export TMP_FOLDER="/tmp/bigwebapps-$USER"
export INI_FILE_WEBAPPS="$HOME_FOLDER/bigwebapps.ini"
export USER_DATA_DIR="$HOME/.cache/.bigwebapps"

# Configurações de tradução
export TEXTDOMAINDIR="/usr/share/locale" # Define o diretório de domínios de texto para traduções
export TEXTDOMAIN=biglinux-webapps       # Define o domínio de texto para o aplicativo

#Título do aplicativo
export TITLE="BigLinux WebApps" # Define o título do aplicativo
export BUTTON_FECHAR="$(gettext $"Fechar")"

# Caminho para os webapps do BigLinux
export WEBAPPS_PATH="/usr/share/bigbashview/bcc/apps/biglinux-webapps"
export WEBAPP_PATH="$WEBAPPS_PATH"
export webapps_path="$WEBAPPS_PATH"
export webapp_path="$WEBAPPS_PATH"

#colors
export red=$(tput setaf 124)
export green=$(tput setaf 2)
export pink=$(tput setaf 129)
export reset=$(tput sgr0)

# Mensagens de erro traduzidas
declare -A Amsg=(
	[error_instance]=$(gettext "Outra instância do Gerenciador de WebApps já está em execução.")
	[error_access_dir]=$(gettext "Erro ao acessar o diretório:")
	[error_browser]=$(gettext "O browser configurado como padrão em $INI_FILE_WEBAPPS não está instalado ou tem erro de configuração.\nClique em fechar para definir para o padrão do BigLinux e continuar!")
	[error_browser_not_installed]=$(gettext "O navegador definido para abrir os WebApps não está instalado! \nTente alterar o navegador no Gerenciador de WebApps!\n")
)
export aBrowserId=('brave' 'brave' 'google-chrome-stable' 'chromium' 'microsoft-edge-stable' 'firefox' 'falkon' 'librewolf' 'vivaldi-stable' 'com.brave.Browser' 'com.google.Chrome' 'org.chromium.Chromium' 'com.microsoft.Edge' 'org.gnome.Epiphany' 'org.mozilla.firefox' 'io.gitlab.librewolf-community' 'com.github.Eloston.UngoogledChromium')
export aBrowserIcon=('brave' 'brave' 'chrome' 'chromium' 'edge' 'firefox' 'falkon' 'librewolf' 'vivaldi' 'brave' 'chrome' 'chromium' 'edge' 'epiphany' 'firefox' 'librewolf' 'ungoogled')
export aBrowserShortName=('brave' 'brave' 'chrome' 'chrome' 'edge' 'firefox' 'falkon' 'librewolf' 'vivaldi' 'brave' 'chrome' 'chromium' 'edge' 'epiphany' 'firefox' 'librewolf' 'ungoogled')
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
	local customDirs="$*"
	local dir

	# Verifica se o diretórios de trabalho existem; se não, cria
	[[ -d "$HOME_FOLDER" ]] || mkdir -p "$HOME_FOLDER"
	[[ -d "$TMP_FOLDER" ]] || mkdir -p "$TMP_FOLDER"
	[[ -d "$HOME_LOCAL"/share/icons ]] || mkdir -p "$HOME_LOCAL"/share/icons
	[[ -d "$HOME_LOCAL"/share/applications ]] || mkdir -p "$HOME_LOCAL"/share/applications
	[[ -d "$HOME_LOCAL"/bin ]] || mkdir -p "$HOME_LOCAL"/bin
	[[ -d "$USER_DATA_DIR" ]] || mkdir -p "$USER_DATA_DIR"

	for dir in "${customDirs[@]}"; do
		[[ -z "$dir" ]] && continue
		[[ -d "$dir" ]] || mkdir -p "$dir"
	done
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_check_dirs

#######################################################################################################################

function sh_check_webapp_is_running() {
	local PID

	if PID=$(pidof webapp-manager-biglinux) && [[ -n "$PID" ]]; then
		#       notify-send -u critical --icon=big-store --app-name "$0" "$TITLE" "${Amsg[error_instance]}" --expire-time=2000
		#       kdialog --title "$TITLE" --icon warning --msgbox "${Amsg[error_instance]}"
		yad --title "$TITLE" \
			--image-on-top \
			--form \
			--fixed \
			--align=center \
			--on-top \
			--center \
			--image=webapp \
			--text "${Amsg[error_instance]}\nPID: $PID" \
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
	local short_new_browser="$2"
	local DESKTOP_FILES
	local CHANGED=0
	local -i nDesktop_Files_Found
	local filename
	local f
	local new_file

	mapfile -t DESKTOP_FILES < <(find "$HOME_LOCAL"/share/applications -iname '*-Default.desktop')
	nDesktop_Files_Found="${#DESKTOP_FILES[@]}"

	if ! ((nDesktop_Files_Found)); then
		sh_webapp_write_new_browser "$new_browser"
		return
	fi

	case "$new_browser" in
	google-chrome-stable) short_new_browser='chrome' ;;
	chromium) short_new_browser='chrome' ;;
	vivaldi-stable) short_new_browser='vivaldi' ;;
	esac

	for f in "${DESKTOP_FILES[@]}"; do
		if [[ "$f" =~ "$old_browser" ]]; then
			new_file="${f/$old_browser/$short_new_browser}"
			mv -f "$f" "$new_file"
			#			TIni.Set "$new_file" "Desktop Entry" "X-WebApp-Browser" "$new_browser"
			CHANGED=1
		fi
	done

	function ChromeToFirefox() {
		for w in "${DESKTOP_FILES[@]}"; do
			filename="${w##*/}"
			cp -f "$WEBAPPS_PATH/assets/$old_browser/bin/${filename%%.*}-$old_browser" "$HOME_LOCAL"/bin
			cp -f "$WEBAPPS_PATH/assets/$old_browser/desk/$filename" "$HOME_LOCAL"/share/applications
		done
	}

	function FirefoxToChrome() {
		for w in "${DESKTOP_FILES[@]}"; do
			cp -f "$WEBAPPS_PATH/webapps/${w##*/}" "$HOME_LOCAL"/share/applications
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
		update-desktop-database -q "$HOME_LOCAL"/share/applications
		nohup kbuildsycoca5 &>/dev/null &
	fi

	sh_webapp_write_new_browser "$new_browser"
}
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
	local short_name
	local nc=0

	for browser in "${aBrowserId[@]}"; do
		if [[ "$browser" = "$new_browser" ]]; then
			cpath="${aBrowserPath[nc]}"
			default_browser="${aBrowserId[nc]}"
			short_name="${aBrowserShortName[nc]}"
			id="${aBrowserId[nc]}"
			icon="${aBrowserIcon[nc]}"
			data_bin="${aBrowserId[nc]}"
			title="${aBrowserTitle[nc]^^}"
			compatible="${aBrowserCompatible[nc]}"
			if [[ "$cpath" =~ '/flatpak/' ]]; then
				flatpak=1
				native=0
			else
				flatpak=0
				native=1
			fi
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "path" "$cpath"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "name" "$default_browser"
			TIni.Set "$INI_FILE_WEBAPPS" "browser" "short_name" "$short_name"
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
	echo "$default_browser"
}
export -f sh_webapp_check_browser

#######################################################################################################################

function sh_webapp_change_icon() {
	local file_icon
	local new_file_icon
	local SUBTITLE="$(gettext $"Selecione o arquivo de imagem")"
	local cancel=1

	cd "$(xdg-user-dir PICTURES)" || return
	file_icon=$(
		yad --title "$SUBTITLE" \
			--file \
			--center \
			--width=900 \
			--height=600 \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--mime-filter=$"Arquivos de Imagem""|image/bmp image/jpeg image/png image/svg+xml image/x-icon"
	)

	if [[ "$?" -eq "$cancel" ]] || [[ -z "$file_icon" ]]; then
		exit
	fi

	new_file_icon=$("$WEBAPPS_PATH"/resize_favicon.sh.py "$file_icon")
	echo "$new_file_icon"
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp_change_icon

#######################################################################################################################

function sh_webapp_backup() {
	# Declaração de variáveis locais
	local subtitle_message="$(gettext $"Não existem WebApps instalados para backup!")"
	local select_directory_title="$(gettext $"Selecione o diretório para salvar:")"
	local backup_filename="backup-webapps_$(date +%Y-%m-%d).tar.gz"
	local temp_backup_dir="$TMP_FOLDER/backup-webapps"
	local temp_bin_dir="$temp_backup_dir/bin"
	local temp_data_dir="$temp_backup_dir/data"
	local temp_icons_dir="$temp_backup_dir/icons"
	local temp_epiphany_dir="$temp_backup_dir/epiphany"
	local temp_portal_dir="$temp_epiphany_dir/xdg-desktop-portal"
	local temp_epiphany_data_dir="$temp_epiphany_dir/data"
	local temp_desktop_dir="$temp_backup_dir/desktop"
	local webapps_list
	local save_directory
	local app_data_folder
	local app_data_folder_copy
	local app_data_dir_copy
	local temp_icon_file
	local temp_bin_file
	local -i num_desktop_files_found
	local -i cancel_status=1

	# Obtém a lista de arquivos .desktop dos WebApps instalados
	mapfile -t webapps_list < <(find "$HOME_LOCAL"/share/applications -iname "*-webapp-biglinux-custom.desktop")
	num_desktop_files_found="${#webapps_list[@]}"

	# Verifica se existem WebApps instalados
	if ! ((num_desktop_files_found)); then
		yad --title="$TITLE" \
			--image=emblem-warning \
			--image-on-top \
			--form \
			--width=500 \
			--height=100 \
			--fixed \
			--align=center \
			--text="$subtitle_message" \
			--button="$BUTTON_CLOSE" \
			--on-top \
			--center \
			--borders=20 \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg"
		exit 1
	fi

	# Solicita ao usuário para selecionar o diretório de salvamento
	cd "$HOME_FOLDER" || return
	save_directory=$(
		yad --title="$select_directory_title" \
			--file \
			--directory \
			--center \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--width=900 --height=600
	)

	# Verifica se o usuário cancelou a operação ou não selecionou um diretório
	if [[ "$?" -eq "$cancel_status" ]] || [[ -z "$save_directory" ]]; then
		exit
	fi

	# Processa cada WebApp encontrado
	for webapp_desktop_file in "${webapps_list[@]}"; do
		# Verifica se o comando de execução contém '.local.bin'
		if grep -q '.local.bin' "$webapp_desktop_file"; then
			mkdir -p "$temp_bin_dir"
			temp_bin_file=$(awk -F'=' '/^Exec/{print $2}' "$webapp_desktop_file")
			cp -a "$temp_bin_file" "$temp_bin_dir"
			app_data_folder=$(sed -n '/^FOLDER/s/.*=\([^\n]*\).*/\1/p' "$temp_bin_file")
			if grep -q '.bigwebapps' <<<"$app_data_folder"; then
				mkdir -p "$temp_data_dir"
				cp -a "$app_data_folder" "$temp_data_dir"
			else
				app_data_folder_copy="$temp_backup_dir/flatpak/$(awk -F'/' '{print $6"/"$7}' <<<"$app_data_folder")"
				mkdir -p "$app_data_folder_copy"
				cp -a "$app_data_folder" "$app_data_folder_copy"
			fi
		fi

		# Verifica se o comando de execução contém 'no.first.run'
		if grep -q '..no.first.run' "$webapp_desktop_file"; then
			app_data_dir=$(awk '/Exec/{sub(/--user-data-dir=/,"");print $2}' "$webapp_desktop_file")
			if grep -q '.bigwebapps' <<<"$app_data_dir"; then
				mkdir -p "$temp_data_dir"
				cp -a "$app_data_dir" "$temp_data_dir"
			else
				app_data_dir_copy="$temp_backup_dir/flatpak/$(awk -F'/' '{print $6"/"$7}' <<<"$app_data_dir")"
				mkdir -p "$app_data_dir_copy"
				cp -a "$app_data_dir" "$app_data_dir_copy"
			fi
		fi

		# Verifica se o comando de execução contém 'profile'
		if grep -q '..profile=' "$webapp_desktop_file"; then
			mkdir -p "$temp_portal_dir"
			cp -a "$HOME_LOCAL"/share/xdg-desktop-portal/* "$temp_portal_dir"
			epiphany_data_dir=$(awk '/Exec/{sub(/--profile=/,"");print $3}' "$webapp_desktop_file")
			mkdir -p "$temp_epiphany_data_dir"
			cp -a "$epiphany_data_dir" "$temp_epiphany_data_dir"
		else
			mkdir -p "$temp_icons_dir"
			temp_icon_file=$(awk -F'=' '/^Icon/{print $2}' "$webapp_desktop_file")
			cp -a "$temp_icon_file" "$temp_icons_dir"
			cp -a "$webapp_desktop_file" "$temp_backup_dir"
		fi

		# Verifica se o arquivo é um link simbólico na área de trabalho do usuário
		if [ -L "$(xdg-user-dir DESKTOP)/${webapp_desktop_file##*/}" ]; then
			mkdir -p "$temp_desktop_dir"
			cp -a "$(xdg-user-dir DESKTOP)/${webapp_desktop_file##*/}" "$temp_desktop_dir"
		fi
	done

	# Cria o arquivo de backup
	cd "$TMP_FOLDER" || return
	tar -czf "${save_directory}/${backup_filename}" backup-webapps

	# Remove o diretório temporário
	rm -r backup-webapps

	# Retorna o caminho do arquivo de backup criado
	echo "${save_directory}/${backup_filename}"
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
				ln -sf "$HOME_LOCAL"/share/xdg-desktop-portal/applications/*.desktop "$HOME_LOCAL"/share/applications
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

function sh_webapp-edit() {
	CHANGE=false
	EDIT=false

	if [[ "$browserOld" != "$browserNew" ]]; then
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
		nohup update-desktop-database -q "$HOME_LOCAL"/share/applications &
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

function sh_webapp_enable-disable() {
	local app="$1"
	local browser_short_name="$2"
	local browser_default
	local app_fullname

	browser_default=$(TIni.Get "$INI_FILE_WEBAPPS" "browser" "id")
	app_fullname="$HOME_LOCAL/share/applications/$browser_short_name-$app"

	if [[ ! -e "$app_fullname" ]]; then
		cp -f "$WEBAPPS_PATH/webapps/$app" "$app_fullname"
		line_exec=$(TIni.Get "$app_fullname" "Desktop Entry" "Exec")
		line_exec+=" $browser_default"
		TIni.Set "$app_fullname" "Desktop Entry" "Exec" "$line_exec"
		echo "X-WebApp-Browser=$browser_default" >> "$app_fullname"
	else
		rm -f "$app_fullname"
	fi

	update-desktop-database -q "$HOME_LOCAL"/share/applications
	nohup kbuildsycoca5 &>/dev/null &
	exit
}
export -f sh_webapp_enable-disable

#######################################################################################################################

function sh_webapp-launch() {
	local parameters="$*"
	local app="$1"
	local browser_default
	local FILE
	local EXEC
	local FILE_WAYLAND

	browser_default=$(TIni.Get "$INI_FILE_WEBAPPS" "browser" "short_name")
	FILE="$HOME_LOCAL/share/applications/$browser_default-$app"

	#xdebug "1-$parameters\n2-$app\n3-$FILE\n4-$browser_default"

	if grep -q '.local.bin' "$FILE"; then
		EXEC=~/$(sed -n '/^Exec/s/.*=~\/\([^\n]*\).*/\1/p' "$FILE")
#		xdebug $EXEC
		"${EXEC}"
	else
		gtk-launch "$browser_default-$app"
	fi
}
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
			DIR_PORTAL_APP="$HOME_LOCAL"/share/xdg-desktop-portal/applications
			DIR_PORTAL_FILEDESK="$DIR_PORTAL_APP/${filedesk##*/}"
			[ -e "$DIR_PORTAL_FILEDESK" ] && rm "$DIR_PORTAL_FILEDESK"
			#rm -r "$EPI_DATA"
		fi

		#if grep -q '.local.bin' "$filedesk";then
		#    DESKBIN="$HOME_LOCAL"/bin/$(sed -n '/^Exec/s/.*\/\([^\/]*\)$/\1/p' "$filedesk")
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

	nohup update-desktop-database -q "$HOME_LOCAL"/share/applications &
	nohup kbuildsycoca5 &>/dev/null &
	printf 0
	exit
}
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-remove-all

#######################################################################################################################

function desktop.get() {
	local file="$1"
	local section="$2"
	local chave="$3"
	local in_section=0

	awk -v section="$section" -v chave="$chave" -F'=' '
    /^\[.*\]$/ {
        in_section = ($0 == "[" section "]") ? 1 : 0
    }
    in_section && $1 ~ chave {
        gsub(/^ +| +$/, "", $2); # Remove leading/trailing spaces
        print $2
        exit
    }
    ' "$file"
}

#######################################################################################################################

function sh_webapp-remove() {
	# Definição das variáveis locais
	local parameters="$*"
	local icon_path
	local desktop_link
	local portal_app_dir
	local portal_desk_file

	# Obtém o caminho do ícone do arquivo .desktop
	icon_path=$(desktop.get "$filedesk" 'Desktop Entry' 'Icon')

	# Cria o caminho para o link na área de trabalho
	desktop_link=$(xdg-user-dir DESKTOP)/"${filedesk##*/}"

	# Verifica se o arquivo .desktop contém a entrada de perfil
	if grep -q '..profile=' "$filedesk"; then
		# Define o diretório para as aplicações do portal
		portal_app_dir="$HOME_LOCAL/share/xdg-desktop-portal/applications"
		# Define o caminho completo do arquivo .desktop no portal
		portal_desk_file="$portal_app_dir/${filedesk##*/}"

		# Remove o arquivo .desktop do portal, se existir
		[[ -e "$portal_desk_file" ]] && rm "$portal_desk_file"
	fi

	# Remove o link na área de trabalho, se existir
	if [[ -L "$desktop_link" ]] || [[ -e "$desktop_link" ]]; then
		unlink "$desktop_link"
	fi

	# Remove o ícone associado, se existir
	[[ -e "$icon_path" ]] && rm "$icon_path"

	# Remove o arquivo .desktop original
	rm "$filedesk"

	# Atualiza a base de dados dos arquivos .desktop
	nohup update-desktop-database -q "$HOME_LOCAL/share/applications" &

	# Atualiza o cache do KDE, se aplicável
	nohup kbuildsycoca5 &>/dev/null &

	exit
}

# Exporta a função para que possa ser utilizada em subshells
export -f sh_webapp-remove

#######################################################################################################################

function sh_webapp-install() {
	local line_exec
	local _session
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
	local short_browser_name="$browser"

	case "$browser" in
	google-chrome-stable) short_browser_name='chrome' ;;
	chromium) short_browser_name='chrome' ;;
	vivaldi-stable) short_browser_name='vivaldi' ;;
	esac

	if grep -qiE 'firefox|librewolf' <<<"$browser"; then
		short_browser_name="$browser"

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
		CLASS="$short_browser_name-webapp-$_NAMEDESK"
		cat >"$DESKBIN" <<-EOF
			#!/usr/bin/env bash

			FOLDER=$DIR_PROF
			CLASS="$short_browser_name-webapp-$_NAMEDESK"

			if [ ! -d "\$FOLDER" ];then
			    mkdir -p "\$FOLDER/chrome"
			    cp -a /usr/share/bigbashview/bcc/apps/biglinux-webapps/profile/userChrome.css "\$FOLDER/chrome"
			    cp -a /usr/share/bigbashview/bcc/apps/biglinux-webapps/profile/user.js "\$FOLDER"
			fi
			MOZ_APP_REMOTINGNAME="\$CLASS" \\
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
			Exec=$DESKBIN $browser
			Icon=${NAME_FILE/.png/}
			Categories=$category;
			X-WebApp-Browser=$browser
			X-WebApp-URL=$urldesk
			Custom=Custom
			X-KDE-StartupNotify=true
		EOF
		chmod +x "$LINK_APP"

		#		if [ "$shortcut" = "on" ]; then
		#			ln -s "$LINK_APP" "$FILE_LINK"
		#			chmod 755 "$FILE_LINK"
		#			gio set "$FILE_LINK" -t string metadata::trust "true"
		#		fi

	elif grep -q 'org.gnome.Epiphany' <<<"$browser"; then
		if ! grep -Eq '^http:|^https:|^localhost|^127' <<<"$urldesk"; then
			urldesk="https://$urldesk"
		fi

		DIR_PORTAL="$HOME_LOCAL"/share/xdg-desktop-portal
		DIR_PORTAL_APP="$DIR_PORTAL"/applications
		DIR_PORTAL_ICON="$DIR_PORTAL"/icons/64x64

		mkdir -p "$DIR_PORTAL_APP"
		mkdir -p "$DIR_PORTAL_ICON"

		FOLDER_DATA="$HOME/.var/app/org.gnome.Epiphany/data/org.gnome.Epiphany.WebApp_$NAME-webapp-biglinux-custom"
		browser="/var/lib/flatpak/exports/bin/org.gnome.Epiphany"
		EPI_FILEDESK="org.gnome.Epiphany.WebApp_$NAME-webapp-biglinux-custom.desktop"
		EPI_DIR_FILEDESK="$DIR_PORTAL_APP/$EPI_FILEDESK"
		EPI_FILE_ICON="$DIR_PORTAL_ICON/${EPI_FILEDESK/.desktop/}.png"
		EPI_LINK="$HOME_LOCAL"/share/applications/"$EPI_FILEDESK"
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
			Icon=${EPI_FILE_ICON/.png/}
			StartupWMClass=$namedesk
			X-WebApp-Browser=$browser
			X-WebApp-URL=$urldesk
			Custom=Custom
			X-Purism-FormFactor=Workstation;Mobile;
			X-Flatpak=org.gnome.Epiphany
		EOF

		chmod +x "$EPI_DIR_FILEDESK"
		ln -s "$EPI_DIR_FILEDESK" "$EPI_LINK"

		#		if [ "$shortcut" = "on" ]; then
		#			ln -s "$EPI_DIR_FILEDESK" "$EPI_DESKTOP_LINK"
		#			chmod 755 "$EPI_DESKTOP_LINK"
		#			gio set "$EPI_DESKTOP_LINK" -t string metadata::trust "true"
		#		fi

		#	elif grep -q 'falkon' <<<"$browser"; then
		#		if ! grep -Eq '^http:|^https:|^localhost|^127' <<<"$urldesk"; then
		#			urldesk="https://$urldesk"
		#		fi
		#
		#		if [ "$newperfil" = "on" ]; then
		#			mkdir -p "$HOME"/.config/falkon/profiles/"$NAME"
		#			browser="$browser -p $NAME -ro"
		#		else
		#			browser="$browser -ro"
		#		fi
		#
		#		if [ "${icondesk##*/}" = "default-webapps.png" ]; then
		#			cp "$icondesk" "$ICON_FILE"
		#		else
		#			mv "$icondesk" "$ICON_FILE"
		#		fi
		#
		#		cat >"$LINK_APP" <<-EOF
		#			[Desktop Entry]
		#			Version=1.0
		#			Terminal=false
		#			Type=Application
		#			Name=$namedesk
		#			Exec=$browser $urldesk
		#			Icon=${NAME_FILE/.png/}
		#			Categories=$category;
		#			X-WebApp-Browser=$browser
		#			X-WebApp-URL=$urldesk
		#			Custom=Custom
		#		EOF
		#		chmod +x "$LINK_APP"

		#		if [ "$shortcut" = "on" ]; then
		#			ln -s "$LINK_APP" "$FILE_LINK"
		#			chmod 755 "$FILE_LINK"
		#			gio set "$FILE_LINK" -t string metadata::trust "true"
		#		fi

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
			browser="$short_browser_name --user-data-dir=$DIR_PROF --no-first-run"
		fi

		if [ "${icondesk##*/}" = "default-webapps.png" ]; then
			cp "$icondesk" "$ICON_FILE"
		else
			mv "$icondesk" "$ICON_FILE"
		fi

		CUT_HTTP=$(sed 's|https://||;s|/|_|g;s|_|__|1;s|_$||;s|_$||;s|&|_|g;s|?||g;s|=|_|g' <<<"$urldesk")

		_session="$(sh_get_desktop_session)"
		case "${_session^^}" in
		X11)
			line_exec="/usr/bin/biglinux-webapp --class=$CUT_HTTP --profile-directory=Default --app=$urldesk $browser"
			;;
		WAYLAND)
			line_exec="/usr/bin/biglinux-webapp --class=$CUT_HTTP,Chromium-browser --profile-directory=Default --app=$urldesk $browser"
			;;
		esac

		cat >"$LINK_APP" <<-EOF
			[Desktop Entry]
			Version=1.0
			Terminal=false
			Type=Application
			Name=$namedesk
			Exec=$line_exec
			Icon=${NAME_FILE/.png/}
			Categories=$category;
			StartupWMClass=$CUT_HTTP
			X-WebApp-Browser=$browser
			X-WebApp-URL=$urldesk
			Custom=Custom
		EOF
		chmod +x "$LINK_APP"

		#		if [ "$shortcut" = "on" ]; then
		#			ln -s "$LINK_APP" "$FILE_LINK"
		#			chmod 755 "$FILE_LINK"
		#			gio set "$FILE_LINK" -t string metadata::trust "true"
		#		fi
	fi

	if [[ -z "$CLASS" ]]; then
		NEW_DESKTOP_FILE="${HOME_LOCAL}/share/applications/${short_browser_name}-${CUT_HTTP}__-Default.desktop"
		mv -f "${LINK_APP}" "${NEW_DESKTOP_FILE}"
	else
		NEW_DESKTOP_FILE="${HOME_LOCAL}/share/applications/${CLASS}.desktop"
		mv -f "${LINK_APP}" "${NEW_DESKTOP_FILE}"
	fi

	if [[ "$shortcut" = "on" ]]; then
		file_link="${NEW_DESKTOP_FILE##*/}"
		ln -sf "$NEW_DESKTOP_FILE" "$USER_DESKTOP/$file_link"
		chmod 755 "$file_link"
		gio set "$file_link" -t string metadata::trust "true"
	fi

	nohup update-desktop-database -q "$HOME_LOCAL"/share/applications &
	nohup kbuildsycoca5 &>/dev/null &

	rm -f /tmp/*.png
	rm -rf /tmp/.bigwebicons
	exit
}
export -f sh_webapp-install

#######################################################################################################################

function sh_webapp-info() {
	# Declaração de variáveis locais
	local desktop_file_name
	local user_desktop_dir
	local app_name
	local app_icon
	local selected_icon
	local app_category
	local exec_command
	local binary_path
	local app_url
	local browser_name
	local profile_checked
	local link_checked

	# Extrai o nome do arquivo .desktop
	desktop_file_name=${filedesk##*/} ## $filedesk vem do .js

	# Obtém o diretório da área de trabalho do usuário
	user_desktop_dir=$(xdg-user-dir DESKTOP)

	# Extrai o nome, ícone, categoria e comando de execução do arquivo .desktop
	app_name=$(awk -F'=' '/Name/{print $2}' "$filedesk")
	app_icon=$(awk -F'=' '/Icon/{print $2}' "$filedesk")
	app_category=$(awk -F'=' '/Categories/{print $2}' "$filedesk")
	exec_command=$(awk '/Exec/{print $0}' "$filedesk")

	# Verifica se o comando de execução contém '.local.bin'
	if grep -q '.local.bin' <<<"$exec_command"; then
		binary_path=$(awk -F'=' '{print $2}' <<<"$exec_command")
		app_url=$(awk '/new-instance/{gsub(/"/, ""); print $7}' "$binary_path")
		browser_name=$(awk '/new-instance/{print $1}' "$binary_path")

	# Verifica se o comando de execução contém 'falkon'
	elif grep -q 'falkon' <<<"$exec_command"; then
		app_url=$(awk '{print $NF}' <<<"$exec_command")
		browser_name=$(awk '{gsub(/Exec=/, ""); print $1}' <<<"$exec_command")

	# Caso contrário, extrai o URL e o nome do navegador do comando de execução
	else
		app_url=$(awk -F'app=' '{print $2}' <<<"$exec_command")
		browser_name=$(awk '{gsub(/Exec=/, ""); print $1}' <<<"$exec_command")
		# Se o URL ainda estiver vazio, tenta outra posição no comando
		if [[ ! "$app_url" ]]; then
			app_url=$(awk '{print $4}' <<<"$exec_command")
		fi
	fi

	# Ajusta o nome do navegador se for um binário do Flatpak
	if grep -q '.var.lib.flatpak.exports.bin' <<<"$browser_name"; then
		browser_name=${browser_name##*/}
	fi

	# Verifica se o comando de execução contém diretório de dados do usuário
	if grep -q '..user.data.dir.' <<<"$exec_command"; then
		profile_checked='checked'
	elif grep -q 'falkon..p' <<<"$exec_command"; then
		profile_checked='checked'
	fi

	# Verifica se o arquivo é um link simbólico
	[[ -L "$user_desktop_dir/$desktop_file_name" ]] && link_checked='checked'

	# Exemplos de casos para diferentes navegadores podem ser adicionados aqui
	case "$browser_name" in
	brave)
		selected_icon='brave'
		selected_brave='selected'
		;;
	com.brave.Browser)
		selected_icon='brave'
		selected_brave_flatpak='selected'
		;;
	google-chrome-stable)
		selected_icon='chrome'
		selected_chrome='selected'
		;;
	com.google.Chrome)
		selected_icon='chrome'
		selected_chrome_flatpak='selected'
		;;
	chromium)
		selected_icon='chromium'
		selected_chromium='selected'
		;;
	org.chromium.Chromium)
		selected_icon='chromium'
		selected_chromium_flatpak='selected'
		;;
	com.github.Eloston.UngoogledChromium)
		selected_icon='ungoogled'
		selected_ungoogled_flatpak='selected'
		;;
	microsoft-edge-stable)
		selected_icon='edge'
		selected_edge='selected'
		;;
	com.microsoft.Edge)
		selected_icon='edge'
		selected_edge_flatpak='selected'
		;;
	org.gnome.Epiphany)
		selected_icon='epiphany'
		selected_epiphany_flatpak='selected'
		;;
	firefox)
		selected_icon='firefox'
		selected_firefox='selected'
		;;
	org.mozilla.firefox)
		selected_icon='firefox'
		selected_firefox_flatpak='selected'
		;;
	librewolf)
		selected_icon='librewolf'
		selected_librewolf='selected'
		;;
	io.gitlab.librewolf-community)
		selected_icon='librewolf'
		selected_librewolf_flatpak='selected'
		;;
	vivaldi-stable)
		selected_icon='vivaldi'
		selected_vivaldi='selected'
		;;
	falkon)
		selected_icon='falkon'
		selected_falkon='selected'
		;;
	*) : ;;
	esac

	case "${app_category/;/}" in
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

	# shellcheck disable=all
	echo -n '
	<div class="content-section">
	  <ul style="margin-top:-20px">
	    <li>
	      <div class="products">
	        <svg viewBox="0 0 512 512">
	          <path fill="currentColor" d="M512 256C512 397.4 397.4 512 256 512C114.6 512 0 397.4 0 256C0 114.6 114.6 0 256 0C397.4 0 512 114.6 512 256zM57.71 192.1L67.07 209.4C75.36 223.9 88.99 234.6 105.1 239.2L162.1 255.7C180.2 260.6 192 276.3 192 294.2V334.1C192 345.1 198.2 355.1 208 359.1C217.8 364.9 224 374.9 224 385.9V424.9C224 440.5 238.9 451.7 253.9 447.4C270.1 442.8 282.5 429.1 286.6 413.7L289.4 402.5C293.6 385.6 304.6 371.1 319.7 362.4L327.8 357.8C342.8 349.3 352 333.4 352 316.1V307.9C352 295.1 346.9 282.9 337.9 273.9L334.1 270.1C325.1 261.1 312.8 255.1 300.1 255.1H256.1C245.9 255.1 234.9 253.1 225.2 247.6L190.7 227.8C186.4 225.4 183.1 221.4 181.6 216.7C178.4 207.1 182.7 196.7 191.7 192.1L197.7 189.2C204.3 185.9 211.9 185.3 218.1 187.7L242.2 195.4C250.3 198.1 259.3 195 264.1 187.9C268.8 180.8 268.3 171.5 262.9 165L249.3 148.8C239.3 136.8 239.4 119.3 249.6 107.5L265.3 89.12C274.1 78.85 275.5 64.16 268.8 52.42L266.4 48.26C262.1 48.09 259.5 48 256 48C163.1 48 84.4 108.9 57.71 192.1L57.71 192.1zM437.6 154.5L412 164.8C396.3 171.1 388.2 188.5 393.5 204.6L410.4 255.3C413.9 265.7 422.4 273.6 433 276.3L462.2 283.5C463.4 274.5 464 265.3 464 256C464 219.2 454.4 184.6 437.6 154.5H437.6z"/>
	        </svg>
	        '$"app_url:"'
	      </div>
	      <!--input type="search" class="input" id="urlDeskEdit" name="urldesk" value="'$app_url'" readonly/-->
	      <input type="search" class="input" id="urlDeskEdit" name="urldesk" value="'$app_url'"/>
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
	      <input type="search" class="input" id="nameDeskEdit" name="namedesk" value="'$app_name'"/>
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
	          <img height="58" width="58" id="browserEdit" src="'icons/$selected_icon.svg'"/>
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
	        <input type="hidden" name="browserOld" value="'$browser_name'"/>
	        <input type="hidden" name="filedesk" value="'$filedesk'"/>
	        <input type="hidden" name="categoryOld" value="'${app_category/;/}'"/>
	        <input type="hidden" name="namedeskOld" value="'$app_name'"/>
	        <input type="hidden" name="icondeskOld" value="'$app_icon'"/>
	      </div>
	    </li>

	    <li>
	      <div class="products">
	        <div class="svg-center" id="imgCategoryEdit">'"$(<./icons/${app_category/;/}.svg)"'</div>
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
#shellcheck disable=SC2155,SC2034,SC2094
# Exporta a função para que ela possa ser usada em subshells e scripts chamados
export -f sh_webapp-info

#######################################################################################################################

function sh_webapp-change_desktop_name_to_wayland() {
	local file
	local FILE_WAYLAND

	for file in "$WEBAPPS_PATH"/webapps/*.desktop; do
		FILE_WAYLAND="${file/.desktop/}"
		FILE_WAYLAND+="__-Default.desktop"
		mv "$file" "$WEBAPPS_PATH/webapps/$FILE_WAYLAND"
	done
}
export -f sh_webapp-change_desktop_name_to_wayland
