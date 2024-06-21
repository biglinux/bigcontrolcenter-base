#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2094
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/shell/weblib.sh
#  Description: Library for BigLinux WebApps
#
#  Created: 2024/05/31
#  Altered: 2024/06/19
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
shopt -s extglob

APP="${0##*/}"
_DATE_ALTERED_="19/06/2024"
_TIME_ALTERED_="09:00"
_VERSION_="1.0.0-20240619"
_WEBLIB_VERSION_="${_VERSION_} - ${_TIME_ALTERED_}"
_UPDATED_="${_DATE_ALTERED_} - ${_TIME_ALTERED_}"
#
export BOOTLOG="/tmp/bigwebapps-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
export HOME_FOLDER="$HOME/.bigwebapps"
export HOME_LOCAL="$HOME/.local"
export TMP_FOLDER="/tmp/bigwebapps-$USER"
export INI_FILE_WEBAPPS="$HOME_FOLDER/bigwebapps.ini"
export USER_DATA_DIR="$HOME_FOLDER/.cache"

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
	[error_browser_config]=$(gettext "O browser configurado como padrão em $INI_FILE_WEBAPPS\nnão está instalado ou tem erro de configuração.\n\nClique em fechar para definir para o padrão do BigLinux e continuar!")
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

function sh_webapp_index_sh_config() {
	declare -g option_value
	declare -g option_text
	declare -g NATIVE=0
	declare -g FLATPAK=0
	declare -g COUNT_BROWSER=0
	declare -g Detectando_o_nome=$(gettext "Detectando o nome, aguarde...")
	declare -g Detectando_o_icone=$(gettext "Detectando o icone, aguarde...")
	declare -g Adicionando_o_webapp=$(gettext "Adicionando o webapp...")
	declare -g Aplicando_as_alteracoes=$(gettext "Aplicando as alterações...")
	declare -g Criando_o_backup=$(gettext "Criando o backup...")
	declare -g Importando_os_webapps=$(gettext "Importando os webapps...")
	declare -g Removendo_o_webapp=$(gettext "Removendo o webapp...")
	declare -g Removendo_todos_os_webapps=$(gettext "Removendo todos os webapps...")
	declare -g Adicionar_WebApps=$(gettext "Adicionar WebApps")
	declare -g Remover_WebApps=$(gettext "Remover WebApps")
	declare -g Editar_WebApp=$(gettext "Editar WebApp")
	declare -g WebApps_Adicionados=$(gettext "WebApps Adicionados")
	declare -g WebApps_BigLinux="WebApps BigLinux"
	declare -g Exemplo=$(gettext "Exemplo")
	declare -g Url_Exemplo="https://www.exemplo.com"
	declare -g URL="URL"
	declare -g Nome=$(gettext "Nome")
	declare -g Icone_do_WebApp=$(gettext "Icone do WebApp")
	declare -g Alterar=$(gettext "Alterar")
	declare -g Cancelar=$(gettext "Cancelar")
	declare -g Aplicar=$(gettext "Aplicar")
	declare -g Adicionar=$(gettext "Adicionar")
	declare -g Fechar=$(gettext "Fechar")
	declare -g Detectar_Nome_e_Icone=$(gettext "Detectar nome e icone")
	declare -g Navegador=$(gettext "Navegador")
	declare -g Categoria=$(gettext "Categoria")
	declare -g Criar_atalho_na_Area_de_Trabalho=$(gettext "Criar atalho na Área de Trabalho")
	declare -g Perfil_Adicional=$(gettext "Perfil Adicional")
	declare -g Desenvolvimento=$(gettext "Desenvolvimento")
	declare -g Escritorio=$(gettext "Escritório")
	declare -g Graficos=$(gettext "Gráficos")
	declare -g Internet=$(gettext "Internet")
	declare -g Jogos=$(gettext "Jogos")
	declare -g Multimidia=$(gettext "Multimidia")
	declare -g WebApps_Nativos=$(gettext "WebApps Nativos")
	declare -g Navegador_padrao=$(gettext "Navegador Padrão")
	declare -g dos=$(gettext "dos")
	declare -g Sim=$(gettext "Sim")
	declare -g Nao=$(gettext "Não")
	declare -g O_navegador_nao_esta_instalado=$(gettext "O navegador não está instalado!")
	declare -g Nao_existem_navegadores_compativeis_instalados_no_sistema=$(gettext "Não existem navegadores compatíveis instalados no sistema!")
	declare -g Selecione_o_navegador_preferido=$(gettext "Selecione o navegador preferido")
	declare -g Voce_deseja_remover_todos_os_WebApps=$(gettext "Você deseja remover todos os WebApps?")
	declare -g Os_WebApps_foram_restaurados_com_sucesso=$(gettext "Os WebApps foram restaurados com sucesso!")
	declare -g O_backup_dos_WebApps_foi_salvo_em=$(gettext "O backup dos WebApps foi salvo em")
	declare -g Selecione_o_icone_preferido=$(gettext "Selecione o ícone preferido")
	declare -g O_WebApp_foi_adicionado_com_sucesso=$(gettext "O WebApp foi adicionado com sucesso!")
	declare -g A_URL_invalida_ou_conexao_falhou=$(gettext "A URL é inválida ou a conexão falhou.")
	declare -g Tente_inserir_o_icone_pelo_botao_Alterar=$(gettext "Tente inserir o ícone pelo botão Alterar.")
	declare -g Para_detectar_o_Nome_e_o_icone=$(gettext "Para detectar o Nome e o Ícone,")
	declare -g voce_precisa_informar_a_URL=$(gettext "você precisa informar a URL.")
	declare -g Para_adicionar_um_WebApp=$(gettext "Para adicionar um WebApp,")
	declare -g voce_precisa_informar_a_URL_e_o_Nome=$(gettext "você precisa informar a URL e o Nome.")
	declare -g Nenhum_WebApp_adicionado=$(gettext "Nenhum WebApp adicionado!")
	declare -g Tem_certeza_que_deseja_remover_este_WebApp=$(gettext "Tem certeza que deseja remover este WebApp?")
	declare -g Importar_Backup=$(gettext "Restaurar Backup")
	declare -g Criar_Backup=$(gettext "Criar Backup")
	declare -g Nativo=$(gettext "Nativo")
	declare -g Sobre=$(gettext "Sobre")
	declare -g CUSTOMFILES
	declare -g NATIVEFILES
}
export -f sh_webapp_index_sh_config

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
export -f sh_webapp_check_dirs

#######################################################################################################################

function sh_webapp_index_sh_setbrowse() {
	local cpath
	local nc=0

	for cpath in "${aBrowserPath[@]}"; do
		if [[ -e "$cpath" ]]; then
			[[ "$cpath" =~ '/flatpak/' ]] && FLATPAK=1 || NATIVE=1
			option_value="${aBrowserId[nc]}"
			option_text="${aBrowserTitle[nc]}"
			((++COUNT_BROWSER))
			cat <<-EOF
				            <option value=$option_value>$option_text</option>
			EOF
		fi
		((++nc))
	done
}
export -f sh_webapp_index_sh_setbrowse

#######################################################################################################################

function sh_pre_process_custom_desktop_files() {
	local allfiles
 	local IsCustom
 	local custom

	mapfile -t allfiles < <(find "$HOME_LOCAL/share/applications" \( -iname "*-Default.desktop" \))
	for custom in "${allfiles[@]}"; do
		if IsCustom=$(desktop.get "$custom" "Desktop Entry" "Custom") && [[ -n "$IsCustom" ]]; then
			CUSTOMFILES+=("$custom")
		else
			NATIVEFILES+=("$custom")
		fi
	done
}
export -f sh_pre_process_custom_desktop_files

#######################################################################################################################

function sh_add_custom_desktop_files() {
#	CUSTOMFILES=""
#	mapfile -t CUSTOMFILES < <(find "$HOME_LOCAL/share/applications" \( -iname "*-Default.desktop" \))

	sh_pre_process_custom_desktop_files

	# Start of gawk script
	gawk -v development="$Desenvolvimento" \
		-v icon_path="$HOME_LOCAL/share/icons" \
		-v office="$Escritorio" \
		-v graphics="$Graficos" \
		-v game="$Jogos" \
		-v audiovideo="$Multimidia" \
		-v internet="$Internet" \
		-v google="Google" \
		-v webapp="WebApps" \
		-v nenhum="$Nenhum_WebApp_adicionado" \
		-v apply="$Aplicar" \
		-v cancel="$Cancelar" \
		-v certeza="$Tem_certeza_que_deseja_remover_este_WebApp" \
		-v restaurar="$Importar_Backup" \
		-v backup="$Criar_Backup" \
		-v all_remove="$Remover_WebApps" \
		-v add="$Adicionar_WebApps" \
		-v adicionar="$Adicionar" -- '

		BEGIN {
			OFS = "\n"
			filesread = 0
			#PROCINFO["sorted_in"] = "@ind_str_asc"
		}

		BEGINFILE {
			if (FILENAME == "-") {
        		++noinput
				exit
			}
			allset = 0
			app_category = name_category = icon = name = deskexec = url = browser = browser_name = name_file = custom = ""
		}

		# Extracting necessary fields
		/^Categories=/ {
			app_category = gensub(/^Categories=|;/, "", "g")

	      # Deploys translations over the name_category variable
   	   # The untranslated texts are assigned using the -v argument in the first line of this script
			switch (app_category) {
        		case /Development/:
          		name_category = development
          		break
        		case /Office/:
          		name_category = office
          		break
        		case /Graphics/:
          		name_category = graphics
          		break
        		case /Network/:
          		name_category = internet
          		break
        		case /Game/:
          		name_category = game
          		break
        		case /AudioVideo/:
          		name_category = audiovideo
          		break
        		case /Webapps/:
          		name_category = webapp
          		break
        		case /Google/:
          		name_category = google
          		break
        		default:
        			# Undefined category found. Skips to next file.
          		nextfile
      	}
		}

		/^Icon=/ {
    		icon = gensub(/^Icon=/, "", 1)
#    		icon = icon_path "/" icon ".png"
    		icon = icon_path "/" icon
		}

		/^Custom=/ {
      	custom = gensub(/^Custom=/, "", 1)
		}

		/^Name=/ {
      	name = gensub(/^Name=/, "", 1)
		}

#    /^Exec=/ {
#      deskexec = gensub(/^Exec=/,"",1)
#
#      if ( /local\/bin/ ) {
#      # Reads the whole amofiexec file as a string, and removes the unimportant parts to keep the url
#      # More info about this maneuver:https://www.gnu.org/software/gawk/manual/html_node/Readfile-Function.html
#        RS_BAK = RS
#        RS = "^$"
#        getline amofiexec < deskexec
#        close(deskexec)
#        RS = RS_BAK
#        url = gensub(/.*new-instance "|" .*$/,"","g",amofiexec)
#        browser_amofiexec = gensub(/.*T_SANDBOX=1 | --cl.*$/,"","g",amofiexec)
#
#        switch(browser_amofiexec){
#          case /firefox/:
#          case /.*org.mozilla.firefox/:
#            browser_name = "firefox"
#            break
#
#          case /librewolf/:
#          case /.*io.gitlab.librewolf-community/:
#            browser_name = "librewolf"
#            break
#        }
#
#      } else if (/.*org.gnome.Epiphany/) {
#        url = $4
#        browser_name = "epiphany"
#      } else if (/falkon/) {
#        url = $NF
#        browser_name = "falkon"
#      } else {
#        url = gensub(/.*app=/,"",1)
#        # pega o 2nd parametro da string Exec=, qual seja o browser
#        #browser_name = gensub(/^Exec=/,"",1,$1)
#        browser_name = gensub(/^Exec=/,"",1,$2)
#      }
#    }

		/^Exec=/ {
      	deskexec = gensub(/^Exec=/,"",1)
	 	}

    	/^X-WebApp-Browser=/ {
      	browser_name = gensub(/^X-WebApp-Browser=/,"",1)
    	}

    	/^X-WebApp-URL=/ {
      	url = gensub(/^X-WebApp-URL=/,"",1)
    	}

    	{
      	switch( browser_name ) {
        		case /brave/:
        		case /.*com.brave.Browser/:
          		browser = "icons/brave.svg"
          		break
        		case /google-chrome-stable/:
        		case /.*com.google.Chrome/:
          		browser = "icons/chrome.svg"
          		break
        		case /chromium/:
				case /.*org.chromium.Chromium/:
          		browser = "icons/chromium.svg"
          		break
        		case /.*com.github.Eloston.UngoogledChromium/:
          		browser = "icons/ungoogled.svg"
          		break
        		case /microsoft-edge-stable/:
        		case /.*com.microsoft.Edge/:
          		browser = "icons/edge.svg"
          		break
        		case /epiphany/:
          		browser = "icons/epiphany.svg"
          		break
        		case /firefox/:
          		browser = "icons/firefox.svg"
          		break
        		case /falkon/:
          		browser = "icons/falkon.svg"
          		break
        		case /librewolf/:
          		browser = "icons/librewolf.svg"
          		break
        		case /vivaldi-stable/:
          		browser = "icons/vivaldi.svg"
          		break
      	}
	   	name_file = gensub(/.*\//, "", 1, FILENAME)
    	}

		# Checking if all necessary variables are set
    	# If all variables are set, skip to ENDFILE block
    	app_category && name_category && icon && name && deskexec && url && browser && custom {
      	++allset
      	nextfile
    	}

    	# Runs after each file is read, or when nextfile statement is called
		ENDFILE {
	  		# Only includes webapps if all variables are set (app_category, name_category, icon, name, etc.)
			if ( allset ) {
				app_array[app_category][FILENAME]["name_file"] = name_file
    			app_array[app_category]["name_category"] = name_category
   	 		app_array[app_category][FILENAME]["name_category"] = name_category
			   app_array[app_category][FILENAME]["icon"] = icon
			   app_array[app_category][FILENAME]["name"] = name
    			app_array[app_category][FILENAME]["url"] = url
    			app_array[app_category][FILENAME]["browser"] = browser
    			++filesread
  			}
		}

		# Runs after all desktop files are read, or if there is no desktop file at all
		END {
	      if ((noinput > 0) || (filesread == 0)) {
				print(\
				    "           <!-- INICIO - TELA QUANDO NÃO ENCONTRAR NENHUM WEBAPP -->",
				    "           <div class=\"content-section\" style=\"margin-top:20%;\">",
				    "             <div style=\"text-align:center;margin:auto;padding:auto;\">",
				    "               <div class=\"content-section-title\" style=\"text-align:center;\">" nenhum "</div>",
				    "               <ul style=\"all:initial\">",
				    "                 <li title=\"Adicionar\" style=\"all:initial\">",
				    "                   <label for=\"tab1\" role=\"button\" id=\"#add-tab-content\" ",
				    "                          style=\"text-align:center;display:flex;justify-content:center;\">",
				    "                     <button class=\"button\" style=\"height:26px;margin-left:-160px\">" adicionar "</button>",
				    "                   </label>",
				    "                   <button class=\"button btn-restore2\" id=\"restore\">" restaurar "</button>",
				    "                 </li>",
				    "               </ul>",
				    "             </div>",
				    "           </div>",
				    "           <!-- FIM - TELA QUANDO NÃO ENCONTRAR NENHUM WEBAPP -->")
				# Because there is no desktop file, we shall exit the script now
				exit
			}
			{
        		print(\
				   "           <div class=\"menu\">",
				   "           <svg viewBox=\"0 0 448 512\">",
				   "             <path d=\"M0 96C0 78.3 14.3 64 32 64H416c17.7 0 32 14.3 32 32s-14.3 32-32 32H32C14.3 128 0 113.7 0 96zM0 256c0-17.7 14.3-32 32-32H416c17.7 0 32 14.3 32 32s-14.3 32-32 32H32c-17.7 0-32-14.3-32-32zM448 416c0 17.7-14.3 32-32 32H32c-17.7 0-32-14.3-32-32s14.3-32 32-32H416c17.7 0 32 14.3 32 32z\"/>",
				   "           </svg>",
				   "             <button class=\"dropdown\">",
				   "               <ul>",
				   "                 <li id=\"backup-li\"><a id=\"backup\">" backup "</a></li>",
				   "                 <li id=\"restore-li\"><a id=\"restore\">" restaurar "</a></li>",
				   "                 <li id=\"add-li\"><a id=\"add\">" add "</a></li>",
				   "                 <li><a id=\"del-all\">" all_remove "</a></li>",
				   "               </ul>",
				   "             </button>",
					"           </div>")
			}

	      n=0
			for (app_category in app_array) {
				# Prints header of the category
				print(\
					"           <div class=\"content-section\" style=\"margin-top:-26px;\" id=\"" app_category "\">",
				   "             <div id=\"" app_category "\" class=\"content-section-title\" style=\"text-align:left;\">",
				                 app_array[app_category]["name_category"], "(<span id=\"" app_category "\"></span>)",
				   "             </div>",
				   "             <ul style=\"margin-top:0px;\" id=\"" app_category "\">")

				for (filename in app_array[app_category]) {
          		# Skips "name_category" index from the app_array[app_category] array
          		if (filename == "name_category") {
            		continue
          		}

          		# Prints info about each webapp installed by the user
          		print(\
						"               <li>",
						"                 <div class=\"products\">",
					  	"                   <div class=\"img-icon\">",
					   "                     <img src=\"" app_array[app_category][filename]["icon"] "\" class=\"svg-center\"/>",
					   "                   </div>",
					   "                   <div class=\"truncate\" style=\"text-align:left\">" app_array[app_category][filename]["name"] "</div>",
					   "                 </div>",
					   "                   <img src=\"" app_array[app_category][filename]["browser"] "\" class=\"img-browser\" />",
					   "                   <div class=\"truncate\">",
					   "                     <a href=\"#!\" onclick=\"_run(`gtk-launch " app_array[app_category][filename]["name_file"] "`)\" class=\"urlCustom\">",
					   "                       <svg viewBox=\"0 0 448 512\" style=\"width:16px;border-radius:0px;margin:0px 0px -3px 0px;display:none;\">",
					   "                         <path fill=\"currentcolor\" d=\"M256 64C256 46.33 270.3 32 288 32H415.1C415.1 32 415.1 32 415.1 32C420.3 32 424.5 32.86 428.2 34.43C431.1 35.98 435.5 38.27 438.6 41.3C438.6 41.35 438.6 41.4 438.7 41.44C444.9 47.66 447.1 55.78 448 63.9C448 63.94 448 63.97 448 64V192C448 209.7 433.7 224 416 224C398.3 224 384 209.7 384 192V141.3L214.6 310.6C202.1 323.1 181.9 323.1 169.4 310.6C156.9 298.1 156.9 277.9 169.4 265.4L338.7 96H288C270.3 96 256 81.67 256 64V64zM0 128C0 92.65 28.65 64 64 64H160C177.7 64 192 78.33 192 96C192 113.7 177.7 128 160 128H64V416H352V320C352 302.3 366.3 288 384 288C401.7 288 416 302.3 416 320V416C416 451.3 387.3 480 352 480H64C28.65 480 0 451.3 0 416V128z\"/>",
					   "                       </svg> ",
					                            app_array[app_category][filename]["url"],
					   "                     </a>",
					   "                   </div>",
					   "                 <div class=\"button-wrapper\">",
					   "                   <a href=\"#!\" onclick=\"editOpen(`" filename "`)\">",
					   "                     <svg viewBox=\"0 0 122.88 119.19\"",
					   "                          style=\"width:21px;border-radius:0px;margin:0px 0px -3px 0px;\">",
					   "                       <path fill=\"currentcolor\" d=\"M104.84 1.62 121.25 18a5.58 5.58 0 0 1 0 7.88L112.17 35l-24.3-24.3L97 1.62a5.6 5.6 0 0 1 7.88 0ZM31.26 3.43h36.3L51.12 19.87H31.26A14.75 14.75 0 0 0 20.8 24.2l0 0a14.75 14.75 0 0 0-4.33 10.46v68.07H84.5A14.78 14.78 0 0 0 95 98.43l0 0a14.78 14.78 0 0 0 4.33-10.47V75.29l16.44-16.44V87.93A31.22 31.22 0 0 1 106.59 110l0 .05a31.2 31.2 0 0 1-22 9.15h-72a12.5 12.5 0 0 1-8.83-3.67l0 0A12.51 12.51 0 0 1 0 106.65v-72a31.15 31.15 0 0 1 9.18-22l.05-.05a31.17 31.17 0 0 1 22-9.16ZM72.33 74.8 52.6 80.9c-13.85 3-13.73 6.15-11.16-6.91l6.64-23.44h0l0 0L83.27 15.31l24.3 24.3L72.35 74.83l0 0ZM52.22 54.7l16 16-13 4c-10.15 3.13-10.1 5.22-7.34-4.55l4.34-15.4Z\"/>",
					   "                     </svg>",
					   "                   </a>",
					   "                 </div>",
					   "                 <div class=\"button-wrapper\" style=\"margin-left:10px;\">",
					   "                   <a href=\"#!\" onclick=\"delOpen(`del" n "`)\">",
					   "                     <svg viewBox=\"0 0 109.484 122.88\"",
					   "                          style=\"width:18px;border-radius:0px;margin:0px 0px -3px 0px;\">",
					   "                       <path fill=\"currentcolor\" d=\"M2.347 9.633h38.297V3.76c0-2.068 1.689-3.76 3.76-3.76h21.144 c2.07 0 3.76 1.691 3.76 3.76v5.874h37.83c1.293 0 2.347 1.057 2.347 2.349v11.514H0V11.982C0 10.69 1.055 9.633 2.347 9.633 L2.347 9.633z M8.69 29.605h92.921c1.937 0 3.696 1.599 3.521 3.524l-7.864 86.229c-0.174 1.926-1.59 3.521-3.523 3.521h-77.3 c-1.934 0-3.352-1.592-3.524-3.521L5.166 33.129C4.994 31.197 6.751 29.605 8.69 29.605L8.69 29.605z M69.077 42.998h9.866v65.314 h-9.866V42.998L69.077 42.998z M30.072 42.998h9.867v65.314h-9.867V42.998L30.072 42.998z M49.572 42.998h9.869v65.314h-9.869 V42.998L49.572 42.998z\"/>",
					   "                    </svg>",
					   "                  </a>",
					   "                </div>",
					   "                <!--REMOVE MODAL ASK-->",
					   "                <div class=\"pop-up\" id=\"del" n "\">",
					   "                  <div class=\"pop-up__subtitle\">" certeza "</div>",
					   "                  <div class=\"content-button-wrapper\">",
					   "                    <button class=\"content-button status-button2 close\">" cancel "</button>",
					   "                    <button class=\"content-button status-button2\" onclick=\"delDesk(`" filename "`)\">" apply "</button>",
					   "                  </div>",
					   "                </div>",
					   "              </li>")
					n++
				}
				print(\
					"	</ul>",
					"	</div>",
					"	<br>")
			}
		}
	' "${CUSTOMFILES[@]}"
	# End of gawk script
}
export -f sh_add_custom_desktop_files

#######################################################################################################################
#
# function sh_add_native_desktop_files() {
# 	# Definindo os diretórios e executando o find para obter os arquivos desejados
# 	mapfile -t bigwebfiles < <(find $WEBAPPS_PATH/webapps \( -iname "*-Default.desktop" \))
#
# 	for app in "${bigwebfiles[@]}"; do
# 		browser_default="$BROWSER"
# 		browser_icon="$ICON"
# 		webapp="${app##*/}"
# 		urldesk="$(desktop.get "$app" "Desktop Entry" "Exec")"
# 		name="$(desktop.get "$app" "Desktop Entry" "Name")"
# 		icon="$(desktop.get "$app" "Desktop Entry" "Icon")"
# 		url="$(desktop.get "$app" "Desktop Entry" "X-WebApp-URL")"
#
# 		if [[ -z "$url" ]]; then
# 			# Remover tudo antes de --app=
# 			app_part=${urldesk#*--app=}
# 			# Extrair somente a URL
# 			url=${app_part%% *}
# 		fi
#
#   	 	color="gray"
#   	 	checked=""
#  		disabled="disabled"
#
# 		for custom in "${CUSTOMFILES[@]}"; do
# 			browser_custom="$(desktop.get "$custom" "Desktop Entry" "X-WebApp-Browser")"
# 			if [[ -e "$HOME_LOCAL/share/applications/$browser_custom-$webapp" ]]; then
# 				browser_icon="$browser_custom"
# 				browser_default="$browser_custom"
# 		    	color="green"
#    		 	checked="checked"
# 	    		disabled=""
#     		fi
#     	done
#
# #		cat <<-EOF
# #	   	<li class="product">
# #			<input value="$webapp" id="webapp_$n" type="checkbox" class="switch" style="margin-right:10px;" $checked />
# #			<div class="products">
# #			<img src="/usr/share/icons/hicolor/scalable/apps/$icon.svg" height="25" width="25" class="svg-center" />
# #			$name
# #	      </div>
# #			<span class="status">
# #			<span id="circle_$n" class="status-circle $color"></span>
# #			<div class="truncate">
# #			<a href="#!" onclick="_run('./webapp-launch.sh $webapp $browser_default');" class="urlNative $disabled" id="link_$n" >
# #			<svg viewBox="0 0 448 512" style="width:16px;border-radius:0px;margin:0px 0px -3px 0px;display:none">
# #			<path fill="currentcolor" d="M256 64C256 46.33 270.3 32 288 32H415.1C415.1 32 415.1 32 415.1 32C420.3 32 424.5 32.86 428.2 34.43C431.1 35.98 435.5 38.27 438.6 41.3C438.6 41.35 438.6 41.4 438.7 41.44C444.9 47.66 447.1 55.78 448 63.9C448 63.94 448 63.97 448 64V192C448 209.7 433.7 224 416 224C398.3 224 384 209.7 384 192V141.3L214.6 310.6C202.1 323.1 181.9 323.1 169.4 310.6C156.9 298.1 156.9 277.9 169.4 265.4L338.7 96H288C270.3 96 256 81.67 256 64V64zM0 128C0 92.65 28.65 64 64 64H160C177.7 64 192 78.33 192 96C192 113.7 177.7 128 160 128H64V416H352V320C352 302.3 366.3 288 384 288C401.7 288 416 302.3 416 320V416C416 451.3 387.3 480 352 480H64C28.65 480 0 451.3 0 416V128z"/>
# #			</svg>
# #			$url
# #			</a>
# #			</div>
# #			</span>
# #			<img src="icons/$browser_icon.svg" height="16" width="16" class="iconBrowser" />
# #			</li>
# #		EOF
#
# 		printf "%s\n" "<li class=\"product\">" \
# 		    "    <input value=\"$webapp\" id=\"webapp_$n\" type=\"checkbox\" class=\"switch\" style=\"margin-right:10px;\" $checked />" \
# 		    "    <div class=\"products\">" \
# 		    "        <img src=\"/usr/share/icons/hicolor/scalable/apps/$icon.svg\" height=\"25\" width=\"25\" class=\"svg-center\" />" \
# 		    "        $name" \
# 		    "    </div>" \
# 		    "    <span class=\"status\">" \
# 		    "        <span id=\"circle_$n\" class=\"status-circle $color\"></span>" \
# 		    "        <div class=\"truncate\">" \
# 		    "            <a href=\"#!\" onclick=\"_run('./webapp-launch.sh $webapp $browser_default');\" class=\"urlNative $disabled\" id=\"link_$n\">" \
# 		    "                <svg viewBox=\"0 0 448 512\" style=\"width:16px;border-radius:0px;margin:0px 0px -3px 0px;display:none;\">" \
# 		    "                    <path fill=\"currentcolor\" d=\"M256 64C256 46.33 270.3 32 288 32H415.1C415.1 32 415.1 32 415.1 32C420.3 32 424.5 32.86 428.2 34.43C431.1 35.98 435.5 38.27 438.6 41.3C438.6 41.35 438.6 41.4 438.7 41.44C444.9 47.66 447.1 55.78 448 63.9C448 63.94 448 63.97 448 64V192C448 209.7 433.7 224 416 224C398.3 224 384 209.7 384 192V141.3L214.6 310.6C202.1 323.1 181.9 323.1 169.4 310.6C156.9 298.1 156.9 277.9 169.4 265.4L338.7 96H288C270.3 96 256 81.67 256 64V64zM0 128C0 92.65 28.65 64 64 64H160C177.7 64 192 78.33 192 96C192 113.7 177.7 128 160 128H64V416H352V320C352 302.3 366.3 288 384 288C401.7 288 416 302.3 416 320V416C416 451.3 387.3 480 352 480H64C28.65 480 0 451.3 0 416V128z\"/>" \
# 		    "                </svg>" \
# 		    "                $url" \
# 		    "            </a>" \
# 		    "        </div>" \
# 		    "    </span>" \
# 		    "    <img src=\"icons/$browser_icon.svg\" height=\"16\" width=\"16\" class=\"iconBrowser\" />" \
# 		    "</li>"
#
# 		((++n))
# 	done
# }
# export -f sh_add_native_desktop_files

#######################################################################################################################

function read_desktop_file_with_read() {
	local file="$1"

	# Loop para ler cada linha do arquivo
	while IFS='=' read -r key value; do
		# Remover espaços em branco do início e do fim de 'value'
		#        value=$(echo "$value" | sed 's/^ *//;s/ *$//')

		# Usar 'case' para capturar os valores das chaves desejadas
		case "$key" in
		"Name") name="$value" ;;
		"Exec") urldesk="$value" ;;
		"Icon") icon="$value" ;;
		"X-WebApp-URL") url="$value" ;;
		*) continue ;; # Ignorar outras chaves não listadas
		esac
	done <"$file"
}
export -f read_desktop_file_with_read

#######################################################################################################################

# Função para ler e extrair valores das chaves usando awk e atribuir ao Bash
function read_desktop_file_with_awk() {
	local file="$1"

	# Usando awk para extrair os campos desejados e imprimir na mesma linha
	IFS="|" read -r name urldesk icon url <<<"$(awk -F ': ' '
		BEGIN {
			FS="="
      	OFS="|"
       	name=""
        	exec=""
        	icon=""
        	url=""
    	}
    	/^Name=/ {
      	sub(/^Name=/, "")  # Remove o prefixo "Name="
        	name=$0             # Atribui ao campo "Name"
    	}
    	/^Exec=/ {
        	sub(/^Exec=/, "")  # Remove o prefixo "Exec="
        	urldesk=$0            # Atribui ao campo "Exec"
    	}
    	/^Icon=/ {
        	sub(/^Icon=/, "")  # Remove o prefixo "Icon="
        	icon=$0            # Atribui ao campo "Icon"
    	}
    	/^X-WebApp-URL=/ {
        	sub(/^X-WebApp-URL=/, "")  # Remove o prefixo "X-WebApp-URL="
        	url=$0                      # Atribui ao campo "X-WebApp-URL"
    	}
   	END {
       	# Imprime os valores capturados na mesma linha
       	print name "|" urldesk "|" icon "|" url;
    	}
	' "$file")"
	# 	xdebug "Name: $name\nExec: $urldesk\nIcon: $icon\nURL: $url"
}
export -f read_desktop_file_with_awk

#######################################################################################################################

# Função para adicionar arquivos nativos de desktop
function sh_add_native_desktop_files() {
	find "$WEBAPPS_PATH/webapps" -iname "*-Default.desktop" |
		while IFS= read -r app; do
			local browser_default="$BROWSER"
			local browser_icon="$ICON"
			local webapp="${app##*/}"
#			local urldesk=$(desktop.get "$app" "Desktop Entry" "Exec")
#		   local name=$(desktop.get "$app" "Desktop Entry" "Name")
#			local icon=$(desktop.get "$app" "Desktop Entry" "Icon")
#			local url=$(desktop.get "$app" "Desktop Entry" "X-WebApp-URL")

			# Chamada da função para ler o arquivo .desktop
			read_desktop_file_with_read "$app"

			# Obter URL se não estiver presente
			[[ -z "$url" ]] && url=$(awk -F'--app=' '{print $2}' <<<"$Exec" | cut -d' ' -f1)

   	 	color="gray"
   	 	checked=""
	  		disabled="disabled"

			# Verificar e definir ícone do navegador personalizado
			mapfile -t NATIVEFILES < <(find "$HOME_LOCAL"/share/applications -iname "*$webapp")
			for custom in "${NATIVEFILES[@]}"; do
				local browser_custom=$(desktop.get "$custom" "Desktop Entry" "X-WebApp-Browser")
				[[ -e "$HOME_LOCAL/share/applications/$browser_custom-$webapp" ]] && {
					browser_default="$browser_custom"
					browser_icon="$browser_custom"
					color="green"
					checked="checked"
					disabled=""
				}
			done

			# Formatar a saída HTML usando printf
			printf "%s\n" "<li class=\"product\">" \
				"    <input value=\"$webapp\" id=\"webapp_$n\" type=\"checkbox\" class=\"switch\" style=\"margin-right:10px;\" $checked />" \
				"    <div class=\"products\">" \
				"        <img src=\"/usr/share/icons/hicolor/scalable/apps/$icon.svg\" height=\"25\" width=\"25\" class=\"svg-center\" />" \
				"        $name" \
				"    </div>" \
				"    <span class=\"status\">" \
				"        <span id=\"circle_$n\" class=\"status-circle $color\"></span>" \
				"        <div class=\"truncate\">" \
				"            <a href=\"#!\" onclick=\"_run('./webapp-launch.sh $webapp $browser_default');\" class=\"urlNative $disabled\" id=\"link_$n\">" \
				"                <svg viewBox=\"0 0 448 512\" style=\"width:16px;border-radius:0px;margin:0px 0px -3px 0px;display:none;\">" \
				"                    <path fill=\"currentcolor\" d=\"M256 64C256 46.33 270.3 32 288 32H415.1C415.1 32 415.1 32 415.1 32C420.3 32 424.5 32.86 428.2 34.43C431.1 35.98 435.5 38.27 438.6 41.3C438.6 41.35 438.6 41.4 438.7 41.44C444.9 47.66 447.1 55.78 448 63.9C448 63.94 448 63.97 448 64V192C448 209.7 433.7 224 416 224C398.3 224 384 209.7 384 192V141.3L214.6 310.6C202.1 323.1 181.9 323.1 169.4 310.6C156.9 298.1 156.9 277.9 169.4 265.4L338.7 96H288C270.3 96 256 81.67 256 64V64zM0 128C0 92.65 28.65 64 64 64H160C177.7 64 192 78.33 192 96C192 113.7 177.7 128 160 128H64V416H352V320C352 302.3 366.3 288 384 288C401.7 288 416 302.3 416 320V416C416 451.3 387.3 480 352 480H64C28.65 480 0 451.3 0 416V128z\"/>" \
				"                </svg>" \
				"                $url" \
				"            </a>" \
				"        </div>" \
				"    </span>" \
				"    <img src=\"icons/$browser_icon.svg\" height=\"16\" width=\"16\" class=\"iconBrowser\" />" \
				"</li>"

			((++n))
		done
}
export -f sh_add_native_desktop_files

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
export -f yadmsg

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
	local DESKTOP_FILES
	local CHANGED=0
	local -i nDesktop_Files_Found
	local f
	local new_file
	local line_exec
	local line_exec_class
	local line_exec_app
	local new_line_exec
	local start_browser_name
	local old_prefix
	local new_prefix
	local IsCustom

	mapfile -t DESKTOP_FILES < <(find "$HOME_LOCAL"/share/applications -iname '*-Default.desktop')
	nDesktop_Files_Found="${#DESKTOP_FILES[@]}"

	if ! ((nDesktop_Files_Found)); then
		sh_webapp_write_new_browser "$new_browser"
		return
	fi

	old_prefix="$old_browser"
	new_prefix="$new_browser"

	case "$old_browser" in
		google-chrome-stable)	old_prefix='chrome';;
		chromium)					old_prefix='chrome';;
		vivaldi-stable)			old_prefix='vivaldi';;
	esac

	case "$new_browser" in
		google-chrome-stable)	new_prefix='chrome';  short_new_browser='chrome';;
		chromium)					new_prefix='chrome';  short_new_browser='chromium';;
		vivaldi-stable)			new_prefix='vivaldi'; short_new_browser='vivaldi';;
	esac

	if ((nDesktop_Files_Found)); then
		for f in "${DESKTOP_FILES[@]}"; do
			if [[ "$f" =~ "$old_prefixr" ]]; then
				if IsCustom=$(TIni.Get "$f" "Desktop Entry" "Custom") && [[ -z "$IsCustom" ]]; then
					new_file="${f/$old_prefix/$new_prefix}"
					if [[ "$f" != "$new_file" ]]; then
						line_exec=$(TIni.Get "$f" "Desktop Entry" "Exec")
					 	line_exec_class="$(sh_webapp_get_param_line_exec "$line_exec" 2)"
					 	line_exec_app="$(sh_webapp_get_param_line_exec "$line_exec" 4)"
						new_line_exec="/usr/bin/biglinux-webapp ${line_exec_class} --profile-directory=Default ${line_exec_app} ${short_new_browser}"
						mv -f "$f" "$new_file"
						TIni.Set "$new_file" 'Desktop Entry' 'Exec' "$new_line_exec"
						TIni.Set "$new_file" 'Desktop Entry' 'X-WebApp-Browser' "$short_new_browser"
						TIni.Set "$new_file" 'Desktop Action SoftwareRender' 'Exec' "SoftwareRender $new_line_exec"
						CHANGED=1
					fi
				fi
			fi
		done
		if ((CHANGED)); then
			update-desktop-database -q "$HOME_LOCAL"/share/applications
			kbuildsycoca5 &>/dev/null &
		fi
	fi

	sh_webapp_write_new_browser "$new_browser"
}
export -f sh_webapp_change_browser

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

	for browser in "${aBrowserShortName[@]}"; do
		if [[ "$browser" = "$default_browser" ]]; then
			return 0
		fi
	done
	return 1
}
export -f sh_webapp_verify_browser

#######################################################################################################################

function sh_webapp_check_browser() {
	local default_browser
	local compatible
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
	local base_file_icon
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
}
export -f sh_webapp_change_icon

#######################################################################################################################

function sh_webapp_backup() {
	# Declaração de variáveis locais
	local webapps_list
	local subtitle_message="$(gettext $"Não existem WebApps instalados para backup!")"
	local select_directory_title="$(gettext $"Selecione o diretório para salvar:")"
	#	local backup_filename="backup-webapps_$(date +%Y-%m-%d).tar.gz"
	local backup_filename="backup-webapps_$(sh_diahora).tar.gz"
	local BACKUP_DIR="$TMP_FOLDER/backup-webapps"
	local temp_icon_file
	local -i num_desktop_files_found
	local -i cancel_status=1
	local backup_files
	local save_directory

	# Obtém a lista de arquivos .desktop dos WebApps instalados
	mapfile -t webapps_list < <(find "$HOME_LOCAL"/share/applications -iname "*-Default.desktop")
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
		return 1
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
	nDesktop_Files_Found=0
	backup_files=()
	for webapp_desktop_file in "${webapps_list[@]}"; do
		temp_icon_file=$(desktop.get "$webapp_desktop_file" 'Desktop Entry', 'Icon')
		[[ -e "$webapp_desktop_file" ]] && backup_files+=("$webapp_desktop_file")
		[[ -e "$HOME_LOCAL/share/icons/$temp_icon_file" ]] && backup_files+=("$HOME_LOCAL/share/icons/$temp_icon_file")
		[[ -L "$(xdg-user-dir DESKTOP)/${webapp_desktop_file##*/}" ]] && backup_files+=("$(xdg-user-dir DESKTOP)/${webapp_desktop_file##*/}")
		nDesktop_Files_Found+=1
	done

	if ((nDesktop_Files_Found)); then
		rsync -qa --relative "${backup_files[@]}" "$BACKUP_DIR"

		# Cria o arquivo de backup
		cd "$BACKUP_DIR/$HOME" || return 1
		tar -I pigz --posix --xattrs -cf "${save_directory}/${backup_filename}" .

		# Remove o diretório temporário
		rm -r "$BACKUP_DIR"

		# Retorna o caminho do arquivo de backup criado
		echo "${save_directory}/${backup_filename}"
		return 0
	fi
	return 1
}
export -f sh_webapp_backup

#######################################################################################################################

function sh_webapp_restore() {
	local restore_subtitle="$(gettext $"Selecionar o arquivo de backup para restaurar: ")"
	local BKP_FOLDER="$TMP_FOLDER/backup-webapps"
	local FLATPAK_FOLDER_DATA="$HOME"/.var/app
	local backup_file
	local cancel=1

	cd "$HOME_FOLDER" || return 1
	backup_file=$(
		yad --title="$restore_subtitle" \
			--file \
			--window-icon="$WEBAPPS_PATH/icons/webapp.svg" \
			--width=900 \
			--height=600 \
			--center \
			--mime-filter=$"Backup WebApps""|application/gzip"
	)
	if [[ "$?" -eq "$cancel" ]] || [[ -z "$backup_file" ]]; then
		echo 1
		return 1
	fi

	if tar -xf "$backup_file" -C "$HOME"; then
		update-desktop-database -q "$HOME_LOCAL"/share/applications &
		kbuildsycoca5 &>/dev/null &
		echo 0
		return 0
	fi
	echo 1
	return 1

}
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
		update-desktop-database -q "$HOME_LOCAL"/share/applications &
		kbuildsycoca5 &>/dev/null &
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

function sh_pre_process_enable_disable_desktop_files() {
	local pattern="$1"
	local patternfiles
	local IsCustom
	local custom
	local result=1
	local CANDIDATEFILES=()

	mapfile -t patternfiles < <(find "$HOME_LOCAL/share/applications" \( -iname "$pattern" \))
	for custom in "${patternfiles[@]}"; do
		if IsCustom=$(desktop.get "$custom" "Desktop Entry" "Custom") && [[ -z "$IsCustom" ]]; then
			CANDIDATEFILES+=("$custom")
			rm -f "$custom"
			result=0
		fi
	done
	echo "$result"
	return "$result"
}

#######################################################################################################################

function sh_webapp_enable-disable() {
	local app="$1"
	local browser_short_name="$2"
	local app_fullname
	local line_exec
	local candidate

	[[ -z "$browser_short_name" ]] && browser_short_name=$(TIni.Get "$INI_FILE_WEBAPPS" "browser" "short_name")
	case "$browser_short_name" in
		google-chrome-stable) browser_short_name='chrome' ;;
		chromium) browser_short_name='chrome' ;;
		vivaldi-stable) browser_short_name='vivaldi' ;;
		*) : ;;
	esac

	app_fullname="$HOME_LOCAL/share/applications/$browser_short_name-$app"

	if ! sh_pre_process_enable_disable_desktop_files "*${app}"; then
		cp -f "$WEBAPPS_PATH/webapps/$app" "$app_fullname"
		line_exec=$(TIni.Get "$app_fullname" "Desktop Entry" "Exec")
		line_exec+=" $browser_short_name"
		TIni.Set "$app_fullname" "Desktop Entry" "Exec" "$line_exec"
		TIni.Set "$app_fullname" "Desktop Entry" "X-WebApp-Browser" "$browser_short_name"
	fi

	sh_pre_process_custom_desktop_files
	update-desktop-database -q "$HOME_LOCAL"/share/applications
	kbuildsycoca5 &>/dev/null &
	exit
}
export -f sh_webapp_enable-disable

#######################################################################################################################

function sh_webapp-launch() {
	local parameters="$*"
	local app="$1"
	local browser_default="$2"
	local desktop_file

	if [[ -z "$browser_default" ]]; then
		browser_default=$(TIni.Get "$INI_FILE_WEBAPPS" "browser" "short_name")
	fi
	desktop_file="$HOME_LOCAL/share/applications/$browser_default-$app"
	if [[ ! -e "$desktop_file" ]]; then
		# tenta localizar o .desktop
		local pattern="*${app}"
		local patternfiles
		local IsCustom
		local custom

		mapfile -t patternfiles < <(find "$HOME_LOCAL/share/applications" \( -iname "$pattern" \))
		for custom in "${patternfiles[@]}"; do
			if IsCustom=$(desktop.get "$custom" "Desktop Entry" "Custom") && [[ -z "$IsCustom" ]]; then
				desktop_file="$custom"
				browser_default=$(desktop.get "$custom" "Desktop Entry" "X-WebApp-Browser")
				break
			fi
		done
	fi
	gtk-launch "$browser_default-$app"
}
export -f sh_webapp-launch

#######################################################################################################################

function sh_webapp_get_param_line_exec() {
	local line_exec="$1"
	local param="$2"
	local array

	# pega o parametro e diminui 1, já que arrays em bash são baseados em zero
	((--param))

	# Converte a string em um array
	IFS=' ' read -r -a array <<< "$line_exec"
	result="${array[$param]}"
	echo "$result"
}
export -f sh_webapp_get_param_line_exec

#######################################################################################################################

function sh_webapp_get_url() {
	local chave_Exec="$1"
	local app_part="${chave_Exec#*--app=}"
	local url="${app_part%% *}"

	echo "$url"
}
export -f sh_webapp_get_url

#######################################################################################################################

function sh_webapp_get_class() {
	local chave_Exec="$1"
	local class_value

	class_value="${chave_Exec#*--class=}"
	class_value="${class_value%% *}"
	class_value="${class_value/,Chromium-browser/}"
	class_value="${class_value/--class=/}"
	class_value="${class_value/www./}"
	echo "$class_value"
}
export -f sh_webapp_get_class

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
export -f desktop.get

#######################################################################################################################

function sh_webapp-remove-all() {
	local webapps_list
	local filedesk
	local config_custom
	local chave_Exec
	local file_icon
	local file_link
	local paramClass
	local cache_dir
	local folder_profile
	local changed=0

	mapfile -t webapps_list < <(find "$HOME_LOCAL"/share/applications -iname "*-Default.desktop")

	for filedesk in "${webapps_list[@]}"; do
		# verifica se o arquivo .desktop é customizado
		if config_custom=$(desktop.get "$filedesk" 'Desktop Entry' 'Custom') && [[ -n "$config_custom" ]]; then
			chave_Exec="$(TIni.Get "$filedesk" 'Desktop Entry' 'Exec')"
			file_icon="$HOME_LOCAL/share/icons/$(desktop.get "$filedesk" 'Desktop Entry' 'Icon')"
			file_link="$(xdg-user-dir DESKTOP)/${filedesk##*/}"

			paramClass="$(desktop.get "$filedesk" 'Desktop Entry' 'StartupWMClass')"
			cache_dir="$USER_DATA_DIR/$paramClass"
			folder_profile="$HOME_FOLDER/$paramClass"

			[[ -e "$file_icon" ]] && rm -v "$file_icon"
			[[ -L "$file_link" || -e "$file_link" ]] && unlink "$file_link"
			[[ -e "$filedesk" ]] && rm -v "$filedesk"

			if [[ -n "$paramClass" ]]; then
				[[ -d "$cache_dir" ]] && rm -rfv "$cache_dir"
				[[ -d "$folder_profile" ]] && rm -rfv "$folder_profile"
			fi
			changed=1
		fi
	done

	if ((changed)); then
		update-desktop-database -q "$HOME_LOCAL"/share/applications &
		kbuildsycoca5 &>/dev/null &
		echo 0
		return
	fi
	echo 1
}
export -f sh_webapp-remove-all

#######################################################################################################################

function sh_webapp-remove() {
	local config_custom
	local chave_Exec
	local file_icon
	local file_link
	local paramClass
	local cache_dir
	local folder_profile

	# verifica se o arquivo .desktop é customizado
	if config_custom=$(desktop.get "$filedesk" 'Desktop Entry' 'Custom') && [[ -n "$config_custom" ]]; then
		chave_Exec="$(TIni.Get "$filedesk" 'Desktop Entry' 'Exec')"
		file_icon="$HOME_LOCAL/share/icons/$(desktop.get "$filedesk" 'Desktop Entry' 'Icon')"
		file_link="$(xdg-user-dir DESKTOP)/${filedesk##*/}"

		paramClass="$(desktop.get "$filedesk" 'Desktop Entry' 'StartupWMClass')"
		cache_dir="$USER_DATA_DIR/$paramClass"
		folder_profile="$HOME_FOLDER/$paramClass"

		[[ -e "$file_icon" ]] && rm -v "$file_icon"
		[[ -L "$file_link" || -e "$file_link" ]] && unlink "$file_link"
		[[ -e "$filedesk" ]] && rm -v "$filedesk"

		if [[ -n "$paramClass" ]]; then
			[[ -d "$cache_dir" ]] && rm -rfv "$cache_dir"
			[[ -d "$folder_profile" ]] && rm -rfv "$folder_profile"
		fi

		update-desktop-database -q "$HOME_LOCAL"/share/applications &
		kbuildsycoca5 &>/dev/null &
		echo 0
		return
	fi
	echo 1
}
export -f sh_webapp-remove

#######################################################################################################################

function sh_webapp-install() {
	local line_exec
	local _session
	local short_browser_name
	local file_link

	# Removendo quebras de linha, tabulações e retorno de carro usando substituição de padrões
	icondesk="${icondesk//$'\n'/}"
	icondesk="${icondesk//$'\r'/}"
	icondesk="${icondesk//$'\t'/}"

	_NAMEDESK=$(sed 's|https\:\/\/||;s|http\:\/\/||;s|www\.||;s|\/.*||;s|\.|-|g' <<<"$urldesk")
	USER_DESKTOP=$(xdg-user-dir DESKTOP)
	LINK_APP="$HOME_LOCAL/share/applications/$_NAMEDESK-$RANDOM-webapp-biglinux-custom.desktop"
	BASENAME_APP="${LINK_APP##*/}"
	NAME="${BASENAME_APP/-webapp-biglinux-custom.desktop/}"
	DIR_PROF="$HOME_FOLDER/$NAME"
	file_link="$USER_DESKTOP/$NAME-webapp-biglinux-custom.desktop"
	BASENAME_ICON="${icondesk##*/}"
	NAME_FILE="${BASENAME_ICON// /-}"
	ICON_FILE="$HOME_LOCAL"/share/icons/"$NAME_FILE"

	case "$browser" in
	google-chrome-stable) short_browser_name='chrome' ;;
	chromium) short_browser_name='chrome' ;;
	vivaldi-stable) short_browser_name='vivaldi' ;;
	*) short_browser_name="$browser" ;;
	esac

	cp "$icondesk" "$ICON_FILE"

	#	if grep -qiE 'firefox|librewolf' <<<"$browser"; then
	if grep -qiE 'gatinho|teeste' <<<"$browser"; then
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

		#			Icon=${NAME_FILE/.png/}
		cat >"$LINK_APP" <<-EOF
			[Desktop Entry]
			Version=1.0
			Terminal=false
			Type=Application
			Name=$namedesk
			Exec=$line_exec
			Icon=$NAME_FILE
			Categories=$category;
			StartupWMClass=$CUT_HTTP
			X-WebApp-Browser=$browser
			X-WebApp-URL=$urldesk
			X-KDE-StartupNotify=true
			Custom=Custom
		EOF
		chmod +x "$LINK_APP"
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
		chmod 755 "$USER_DESKTOP/$file_link"
		gio set "$USER_DESKTOP/$file_link" -t string metadata::trust "true"
	fi

	update-desktop-database -q "$HOME_LOCAL"/share/applications &
	kbuildsycoca5 &>/dev/null &

	rm -f /tmp/*.png
	rm -rf /tmp/.bigwebicons
	exit
}
export -f sh_webapp-install

#######################################################################################################################

function sh_webapp-info() {
	local desktop_file_name
	local user_desktop_dir
	local app_name
	local app_icon
	local app_category
	local exec_command
	local selected_icon
	local binary_path
	local app_url
	local browser_name
	local profile_checked
	local link_checked
	local IsCustom

	# Extrai o nome do arquivo .desktop
	desktop_file_name="${filedesk##*/}" ## $filedesk vem do .js

	# Obtém o diretório da área de trabalho do usuário
	user_desktop_dir=$(xdg-user-dir DESKTOP)

	# Extrai o nome, ícone, categoria e comando de execução do arquivo .desktop
	app_name="$(desktop.get "$filedesk" 'Desktop Entry' 'Name')"
	app_category="$(desktop.get "$filedesk" 'Desktop Entry' 'Categories')"
	browser_name="$(desktop.get "$filedesk" 'Desktop Entry' 'X-WebApp-Browser')"
	app_url="$(desktop.get "$filedesk" 'Desktop Entry' 'X-WebApp-URL')"
	exec_command="$(TIni.Get "$filedesk" 'Desktop Entry' 'Exec')"
	IsCustom="$(desktop.get "$filedesk" 'Desktop Entry' 'Custom')"
	app_icon="$(desktop.get "$filedesk" 'Desktop Entry' 'Icon')"

	if [[ -n "$IsCustom" ]]; then
		app_icon="$HOME_LOCAL/share/icons/$app_icon"
	fi

	# Verifica se o comando de execução contém diretório de dados do usuário
	if grep -q '..user.data.dir.' <<<"$exec_command"; then
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
export -f sh_webapp-info

#######################################################################################################################
