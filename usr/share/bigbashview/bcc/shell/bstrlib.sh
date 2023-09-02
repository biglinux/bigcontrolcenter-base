#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2317,SC2143
#shellcheck source=/dev/null

#  bstrlib.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2023/08/11
#  Altered: 2023/09/01
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

export HOME_FOLDER="$HOME/.bigstore"
export TMP_FOLDER="/tmp/bigstore-$USER"
unset GREP_OPTIONS
#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store
declare -g Programas_AUR=$"Programas AUR"
declare -g Programas_Flatpak=$"Programas Flatpak"
declare -g Programas_Nativos=$"Programas Nativos"
declare -g flatpak_versao=$"Versão: "
declare -g flatpak_pacote=$"Pacote: "
declare -g flatpak_nao_infomada=$"Não informada"
declare -gA PKG_FLATPAK

function sh_flatpak_installed_list {
	# Le os pacotes instalados em flatpak
	local FLATPAK_INSTALLED_LIST="|$(flatpak list | cut -f2 -d$'\t' | tr '\n' '|')"
	echo "$FLATPAK_INSTALLED_LIST"
}

function sh_seek_flatpak_parallel_filter() {
	local package="$1"
	local myarray

	mapfile -t -d"|" myarray <<<"$package"
	PKG_FLATPAK[PKG_NAME]="${myarray[0]}"
	PKG_FLATPAK[PKG_DESC]="${myarray[1]}"
	PKG_FLATPAK[PKG_ID]="${myarray[2]}"
	PKG_FLATPAK[PKG_VERSION]="${myarray[3]}"
	PKG_FLATPAK[PKG_STABLE]="${myarray[4]}"
	PKG_FLATPAK[PKG_REMOTE]="${myarray[5]}"
	PKG_FLATPAK[PKG_UPDATE]="${myarray[6]}"

	# Seleciona o arquivo xml para filtrar os dados
	PKG_FLATPAK[PKG_XML_APPSTREAM]="/var/lib/flatpak/appstream/${PKG_FLATPAK[PKG_REMOTE]}/x86_64/active/appstream.xml"
	if [[ -z "${PKG_FLATPAK[PKG_VERSION]}" ]]; then
		PKG_FLATPAK[PKG_VERSION]="$flatpak_nao_informada"
	fi

	# Search icon
	PKG_FLATPAK[PKG_ICON]="$(find /var/lib/flatpak/appstream/ -type f -iname "${PKG_FLATPAK[PKG_ID]}.png" -print -quit)"

	# If not found try another way
	if [[ -z "${PKG_FLATPAK[PKG_ICON]}" ]]; then
		# If cached icon not found, try online
		PKG_FLATPAK[PKG_ICON]="$(awk /\<id\>${PKG_FLATPAK[PKG_ID]}\<\\/id\>/,/\<\\/component\>/ ${PKG_FLATPAK[PKG_XML_APPSTREAM]} | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g')"

		# If online icon not found, try another way
		if [[ -z "${PKG_FLATPAK[PKG_ICON]}" ]]; then
			PKG_FLATPAK[PKG_ICON]="$(awk /\<id\>${PKG_FLATPAK[PKG_ID]}.desktop\<\\/id\>/,/\<\\/component\>/ ${PKG_FLATPAK[PKG_XML_APPSTREAM]} | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g')"
		fi
	fi
}

function sh_search_flatpak() {
	# Le o parametro passado via terminal e cria a variavel $search
	local search="$*"

	# Le os pacotes instalados em flatpak
	FLATPAK_INSTALLED_LIST=$(sh_flatpak_installed_list)

	#	xdebug "$0[$LINENO]: $search"
	#	xdebug "$FLATPAK_INSTALLED_LIST"
	#	xdebug "$search"

	# Inicia uma função para possibilitar o uso em modo assíncrono
	function flatpak_parallel_filter() {
		local package="$1"
		sh_seek_flatpak_parallel_filter "$package"

		# Improve order of packages
		PKG_NAME_CLEAN="${search% *}"

		# Verify if package are installed
		if [[ "$FLATPAK_INSTALLED_LIST" == *"|${PKG_FLATPAK[PKG_ID]}|"* ]]; then
			if [ -n "$(tr -d '\n' <<<"${PKG_FLATPAK[PKG_UPDATE]}")" ]; then
				PKG_FLATPAK[PKG_INSTALLED]=$"Atualizar"
				PKG_FLATPAK[DIV_FLATPAK_INSTALLED]="flatpak_upgradable"
				PKG_FLATPAK[PKG_ORDER]="FlatpakP1"
			else
				PKG_FLATPAK[PKG_INSTALLED]=$"Remover"
				PKG_FLATPAK[DIV_FLATPAK_INSTALLED]="flatpak_installed"
				PKG_FLATPAK[PKG_ORDER]="FlatpakP1"
			fi
		else
			PKG_FLATPAK[PKG_INSTALLED]=$"Instalar"
			PKG_FLATPAK[DIV_FLATPAK_INSTALLED]="flatpak_not_installed"

			if grep -q -i -m1 "$PKG_NAME_CLEAN" <<<"${PKG_FLATPAK[PKG_ID]}"; then
				PKG_FLATPAK[PKG_ORDER]="FlatpakP2"
			elif grep -q -i -m1 "$PKG_NAME_CLEAN" <<<"${PKG_FLATPAK[PKG_ID]}"; then
				PKG_FLATPAK[PKG_ORDER]="FlatpakP3"
			else
				PKG_FLATPAK[PKG_ORDER]="FlatpakP4"
			fi
		fi

		# If all fail, use generic icon
		if [[ -z "${PKG_FLATPAK[PKG_ICON]}" || -n "$(LC_ALL=C grep -i -m1 -e 'type=' -e '<description>' <<<"${PKG_FLATPAK[PKG_ICON]}")" ]]; then
			cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
				<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=${PKG_FLATPAK[PKG_NAME]}">
				<div class="col s12 m6 l3" id="${PKG_FLATPAK[PKG_ORDER]}">
				<div class="showapp">
				<div id="flatpak_icon">
				<div class="icon_middle">
				<div class="icon_middle">
				<div class="avatar_flatpak">
				${PKG_FLATPAK[PKG_NAME]:0:3}
				</div></div></div>
				<div id="flatpak_name">
				${PKG_FLATPAK[PKG_NAME]}
				<div id="version">
				${PKG_FLATPAK[PKG_VERSION]}
				</div></div></div>
				<div id="box_flatpak_desc">
				<div id="flatpak_desc">
				${PKG_FLATPAK[PKG_DESC]}
				</div></div>
				<div id="${PKG_FLATPAK[DIV_FLATPAK_INSTALLED]}">
				${PKG_FLATPAK[PKG_INSTALLED]}
				</div></a></div></div>
			EOF
		else
			cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
				<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=${PKG_FLATPAK[PKG_ID]}">
				<div class="col s12 m6 l3" id="${PKG_FLATPAK[PKG_ORDER]}">
				<div class="showapp">
				<div id="flatpak_icon">
				<div class="icon_middle">
				<img class="icon" loading="lazy" src="${PKG_FLATPAK[PKG_ICON]}">
				</div>
				<div id="flatpak_name">
				${PKG_FLATPAK[PKG_NAME]}
				<div id="version">
				${PKG_FLATPAK[PKG_VERSION]}
				</div></div></div>
				<div id="box_flatpak_desc">
				<div id="flatpak_desc">
				${PKG_FLATPAK[PKG_DESC]}
				</div></div>
				<div id="${PKG_FLATPAK[DIV_FLATPAK_INSTALLED]}">
				${PKG_FLATPAK[PKG_INSTALLED]}
				</div></a></div></div>
			EOF
		fi
	}

	if [[ -z "$resultFilter_checkbox" ]]; then
		cacheFile="$HOME_FOLDER/flatpak.cache"
	else
		cacheFile="$HOME_FOLDER/flatpak_filtered.cache"
	fi

	local COUNT=0
	local LIMITE=10000

	for i in ${search[@]}; do
		#xdebug "$i"
		if result="$(grep -i -e "$i" "$cacheFile")" && [[ -n "$result" ]]; then
			#xdebug "$result"
			while IFS= read -r line; do
				((++COUNT))
				flatpak_parallel_filter "$line" &
				if [ "$COUNT" = "$LIMITE" ]; then
					break
				fi
			done <<<"$result"
		fi
	done

	# Aguarda todos os resultados antes de exibir para o usuário
	wait

	if ((COUNT)); then
		echo "$COUNT" >"$TMP_FOLDER/flatpak_number.html"
		cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
			<script>runAvatarFlatpak();\$(document).ready(function () {\$("#box_flatpak").show();});</script>
			<script>$(document).ready(function() {$("#box_flatpak").show();});</script>
		EOF
	fi
	echo '<script>document.getElementById("flatpak_icon_loading").innerHTML = ""; runAvatarFlatpak();</script>' >>"$TMP_FOLDER/flatpak_build.html"
	cp -f "${TMP_FOLDER}/flatpak_build.html" "${TMP_FOLDER}/flatpak.html"
}
export -f sh_search_flatpak

function sh_search_snap() {
	# Le o parametro passado via terminal e cria a variavel $search
	local search="$*"
	declare -g VERSION=$"Versão: "
	declare -g PACKAGE=$"Pacote: "
	declare -g snap_cache_file="$HOME_FOLDER/snap.cache"

	# Lê os pacotes instalados em snap
	SNAP_INSTALLED_LIST="|$(awk 'NR>1 {printf "%s|", $1} END {printf "\b\n"}' <(snap list))"

	# Remova o comentário para fazer testes no terminal
	#search=office

	# Inicia uma função para possibilitar o uso em modo assíncrono
	snap_parallel_filter() {
		mapfile -t -d"|" myarray <<<"$1"
		PKG_NAME="${myarray[0]}"
		PKG_ID="${myarray[1]}"
		PKG_ICON="${myarray[2]}"
		PKG_DESC="${myarray[3]}"
		PKG_VERSION="${myarray[4]}"
		PKG_CMD="${myarray[5]}"

		#xdebug "$PKG_NAME\n$PKG_ID\n$PKG_ICON\n$PKG_DESC\n$PKG_VERSION\n$PKG_CMD"

		#Melhora a ordem de exibição dos pacotes, funciona em conjunto com o css que irá reordenar
		#de acordo com o id da div, que aqui é representado pela variavel $PKG_ORDER
		PKG_NAME_CLEAN="${search%% *}"

		# Verifica se o pacote está instalado
		if [[ "${SNAP_INSTALLED_LIST,,}" == *"|$PKG_CMD|"* ]]; then
			PKG_INSTALLED=$"Remover"
			DIV_SNAP_INSTALLED="appstream_installed"
			PKG_ORDER="SnapP1"
		else
			PKG_INSTALLED=$"Instalar"
			DIV_SNAP_INSTALLED="appstream_not_installed"

			PKG_ORDER="SnapP3"
			[[ "${PKG_NAME} ${PKG_CMD}" == *"${PKG_NAME_CLEAN}"* ]] && PKG_ORDER="SnapP2"

			PKG_ORDER="SnapP3"
			[[ "${PKG_NAME} ${PKG_CMD}" == *"${PKG_NAME_CLEAN}"* ]] && PKG_ORDER="SnapP2"
		fi
		if [[ -z "$PKG_ICON" ]]; then
			cat >>"$TMP_FOLDER/snap_build.html" <<-EOF
				<!--$PKG_NAME-->
				<a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID">
				<div class="col s12 m6 l3" id="$PKG_ORDER">
				<div class="showapp">
				<div id="snap_icon">
				<div class="icon_middle">
				<div class="avatar_snap">
				${PKG_NAME:0:3}
				</div>
				</div>
				<div id="snap_name">
				$PKG_NAME
				<div id="version">
				$PKG_VERSION
				</div>
				</div>
				</div>
				<div id="box_snap_desc">
				<div id="snap_desc">
				$PKG_DESC
				</div>
				</div>
				<div id="$DIV_SNAP_INSTALLED">
				$PKG_INSTALLED
				</div>
				</a>
				</div>
				</div>
			EOF
		else
			cat >>"$TMP_FOLDER/snap_build.html" <<-EOF
				<!--$PKG_NAME-->
				<a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID">
				<div class="col s12 m6 l3" id="$PKG_ORDER">
				<div class="showapp">
				<div id="snap_icon">
				<div class="icon_middl">
				<img class="icon" loading="lazy" src="$PKG_ICON">
				</div>
				<div id="snap_name">
				$PKG_NAME
				<div id="version">
				$PKG_VERSION
				</div>
				</div>
				</div>
				<div id="box_snap_desc">
				<div id="snap_desc">
				$PKG_DESC
				</div>
				</div>
				<div id="$DIV_SNAP_INSTALLED">
				$PKG_INSTALLED
				</div>
				</a>
				</div>
				</div>
			EOF
		fi
	}

	# Inicia o loop, filtrando o conteudo do arquivo ${HOME_FOLDER}/snap.cache
	[[ -e "$TMP_FOLDER/snap_build.html" ]] && rm -f "$TMP_FOLDER/snap_build.html"
	[[ -e "$TMP_FOLDER/snap.html" ]] && rm -f "$TMP_FOLDER/snap.html"
	[[ -e "$TMP_FOLDER/snap_number.html" ]] && rm -f "$TMP_FOLDER/snap_number.html"

	if [[ -z "$resultFilter_checkbox" ]]; then
		cacheFile="${HOME_FOLDER}/snap.cache"
	else
		cacheFile="${HOME_FOLDER}/snap_filtered.cache"
	fi

	local COUNT=0
	local LIMITE=10000

	#xdebug "$search"
	for i in ${search[@]}; do
		#xdebug "$i"
		if result="$(grep -i -e "$i" "$cacheFile")" && [[ -n "$result" ]]; then
			#xdebug "$result"
			while IFS= read -r line; do
				((++COUNT))
				snap_parallel_filter "$line" &
				if [ "$COUNT" = "$LIMITE" ]; then
					break
				fi
			done <<<"$result"
		fi
	done

	# Aguarda todos os resultados antes de exibir para o usuário
	wait

	if ((COUNT)); then
		echo "$COUNT" >"$TMP_FOLDER/snap_number.html"
		cat >>"$TMP_FOLDER/snap_build.html" <<-EOF
			<script>runAvatarSnap();\$(document).ready(function () {\$("#box_snap").show();});</script>
			<script>$(document).ready(function() {$("#box_snap").show();});</script>
		EOF
	fi
	echo '<script>document.getElementById("snap_icon_loading").innerHTML = ""; runAvatarSnap();</script>' >>"$TMP_FOLDER/snap_build.html"
	cp -f "${TMP_FOLDER}/snap_build.html" "${TMP_FOLDER}/snap.html"

}
export -f sh_search_snap

function sh_search_aur {
	local search="$*"
	local install_text=$"Instalar"
	local remove_text=$"Remover"
	local -i n=1
	local -i total=0
	local cmd

	[[ -e "${TMP_FOLDER}/aur_build.html" ]] && rm -f "${TMP_FOLDER}/aur_build.html"

	cmd="$(LC_ALL=C paru -Ssa $@ --limit 60 --sortby popularity --searchby name-desc)"
	while read -r line; do
		if [[ $line == aur/* ]]; then
			pkg=${line#aur/}
			pkg=${pkg%% *}
			pkgicon=${pkg//-bin/}
			pkgicon=${pkgicon//-git/}
			pkgicon=${pkgicon//-beta/}
			title=${pkg//-/ }
			unset title_uppercase_first_letter

			for word in $title; do
				title_uppercase_first_letter+=" ${word^}"
			done

			version=${line#* }
			version=${version%% *}

			if [[ $line = *' [Installed]'* || $line = *'Installed'* ]]; then
				button="<div id=aur_installed>$remove_text</div>"
				aur_priority="AurP1"
			else
				button="<div id=aur_not_installed>$install_text</div>"
				if [[ "$1" =~ .*"$title".* ]]; then
					aur_priority="AurP2"
				else
					aur_priority="AurP3"
				fi
			fi

			if [ -e "icons/$pkgicon.png" ]; then
				icon="<img class=\"icon\" src=\"icons/$pkgicon.png\">"
			elif [ -e "/usr/share/bigbashview/bcc/apps/big-store/description/$pkgicon/flatpak_icon.txt" ]; then
				if [ -e "$(</usr/share/bigbashview/bcc/apps/big-store/description/$pkgicon/flatpak_icon.txt)" ]; then
					icon="<img class=\"icon\" src=\"$(</usr/share/bigbashview/bcc/apps/big-store/description/$pkgicon/flatpak_icon.txt)\">"
				else
					icon="<div class=avatar_aur>${pkgicon:0:3}</div>"
				fi
			else
				icon="<div class=avatar_aur>${pkgicon:0:3}</div>"
			fi

			if [ -e "description/$pkg/pt_BR/summary" ]; then
				summary=$(<description/$pkg/pt_BR/summary)
			else
				summary=$line
			fi

			{
				echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=$pkg\">"
				echo "<div class=\"col s12 m6 l3\" id=$aur_priority>"
				echo "<div class=\"showapp\">"
				echo "<div id=aur_icon><div class=icon_middle>$icon</div>"
				echo "<div id=aur_name><div id=limit_title_name>$title_uppercase_first_letter</div>"
				echo "<div id=version>$version</div></div></div>"
				echo "<div id=box_aur_desc><div id=aur_desc>$summary</div></div>"
				echo "$button</a></div></div>"
			} >>"$TMP_FOLDER/aur_build.html"
			((++total))
		else
			continue
		fi

	done <<<"$cmd"

	echo "$total" >"$TMP_FOLDER/aur_number.html"
	if ((total)); then
		echo '<script>$(document).ready(function() {$("#box_aur").show();});</script>' >>"$TMP_FOLDER/aur_build.html"
	fi
	echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"

	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
}
export -f sh_search_aur

function sh_search_aur_category {
	local search="$*"

	[[ -e "$TMP_FOLDER/aur_build.html" ]] && rm -f "$TMP_FOLDER/aur_build.html"
	[[ -e "$TMP_FOLDER/aur_number.html" ]] && rm -f "$TMP_FOLDER/aur_number.html"

	LANGUAGE=C yay -Sia $search --topdown | gawk -v tmpfolder="${TMP_FOLDER}" -v instalar=$"Instalar" -v remover=$"Remover" -- '
    ### Begin of gawk script

    BEGIN {
        OFS = "\n"
    }

    # Following block runs when blank line found, i.e., on the transition between packages
    !$0 {
        title = version = description = not_installed = idaur = button = skipping = ""
    }

    # Skips lines between packages
    skipping {
        next
    }

    /^Name/ {
        title = gensub(/^Name +: /,"",1)
        not_installed = system("pacman -Q " title " 2> /dev/null 1> /dev/null")
        if ( not_installed ) {
            idaur = "AurP2"
            button = "<div id=aur_not_installed>" instalar "</div></a></div></div>"
        } else {
            idaur = "AurP1"
            button = "<div id=aur_installed>" remover "</div></a></div></div>"
        }
    }

    /^Version/ {
        version = gensub(/^Version +: /,"",1)
    }

    /^Description/ {
        description = gensub(/^Description +: /,"",1)
    }

    # When all variables are set
    title && version && description && idaur && button {
        if ( system("[ ! -e icons/" title ".png ]") ) {
            icon = "<img class=\"icon\" src=\"icons/" title ".png\">"
        } else {
            icon = "<div class=avatar_aur>" substr(title,1,3) "</div>"
        }

    # Checking custom localized description
        shortlang = gensub(/\..+/,"",1,ENVIRON["LANG"])
        summaryfile = "description/" title "/" shortlang "/summary"
    # Double negative because system() returns exit status of shell command inside ()
        if ( !system("[ -e " summaryfile " ]") ) {
            RS_BAK = RS
            RS = "^$"
            getline description < summaryfile
            close(summaryfile)
            RS = RS_BAK
        }

    # Writes html of current package on aur_build.html
    # Do not worry, file redirector ">" works different in awk: only the first interaction deletes file content
        print(\
    "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=" title "\">",
    "<div class=\"col s12 m6 l3\" id=" idaur ">",
    "<div class=\"showapp\">",
    "<div id=aur_icon><div class=icon_middle>" icon "</div>",
    "<div id=aur_name><div id=limit_title_name>" title "</div>",
    "<div id=version>" version "</div></div></div>",
    "<div id=box_aur_desc><div id=aur_desc>" description "</div></div>",
    button) > tmpfolder "/aur_build.html"

        count++
        skipping++
    # Getting ready for next package
        title = version = description = not_installed = idaur = icon = button = ""
    }

    END{
        if (count) {
            print(\
    "<script>$(document).ready(function() {$(\"#box_aur\").show();});</script>",
    "<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\";</script>",
    "<script>runAvatarAur();</script>") > tmpfolder "/aur_build.html"
        } else {
            print(\
    "<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\";</script>",
    "<script>runAvatarAur();</script>") > tmpfolder "/aur_build.html"
        }
    print(count) > tmpfolder "/aur_number.html"
    }
    '
	# End of gawk script

	if [[ -e "$TMP_FOLDER/aur_number.html" ]]; then
		echo '<script>$(document).ready(function() {$("#box_aur").show();});</script>' >>"$TMP_FOLDER/aur_build.html"
	fi
	echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"

	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
}
export -f sh_search_aur_category

function sh_reinstall_allpkg {
	pacman -Sy --noconfirm - < <(pacman -Qnq)
}
export -f sh_reinstall_allpkg

function sh_pkg_pacman_install_date {
	#	grep "^Install Date " "${TMP_FOLDER}/pacman_pkg_cache.txt" | cut -f2 -d:
	local install_date
	local formatted_date

	if install_date=$(grep -oP 'Install Date\s*:\s*\K.*' "$TMP_FOLDER/pacman_pkg_cache.txt") && [[ -n "$install_date" ]]; then
		formatted_date=$(date -d "$install_date" "+%a %b %d %H:%M:%S %Y" | LC_TIME=$LANG sed 's/^\([a-zA-Z]\)/\u\1/')
		echo "$formatted_date"
	fi
}
export -f sh_pkg_pacman_install_date

function sh_pkg_pacman_install_reason {
	grep "^Install Reason " "$TMP_FOLDER/pacman_pkg_cache.txt" | cut -f2 -d:
}
export -f sh_pkg_pacman_install_reason

function search_appstream_pamac {
	[[ -e "$TMP_FOLDER/appstream_build.html" ]] && rm -f "$TMP_FOLDER/appstream_build.html"
	echo "" >"$TMP_FOLDER/upgradeable.txt"
	pacman -Qu | cut -f1 -d" " >>"$TMP_FOLDER/upgradeable.txt"
	./search_appstream_pamac "${@}" >>"$TMP_FOLDER/appstream_build.html"
	mv "$TMP_FOLDER/appstream_build.html" "$TMP_FOLDER/appstream.html"
}

#qua 23 ago 2023 22:44:29 -04
function sh_pkg_pacman_version {
	grep "^Version " "${TMP_FOLDER}/pacman_pkg_cache.txt" | cut -f2-10 -d: | awk 'NF'
}
export -f sh_pkg_pacman_version

function sh_count_snap_list {
	local snap_count=$(snap list | wc -l)
	((snap_count -= 1))
	echo "$snap_count"
}
export -f sh_count_snap_list

function sh_count_snap_cache_lines {
	wc -l <"$HOME_FOLDER/snap.cache"
}
export -f sh_count_snap_cache_lines

function sh_SO_installation_date {
	#	ls -lct /etc | tail -1 | awk '{print $6, $7, $8}')
	expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | head -n 1
}
export -f sh_SO_installation_date

function sh_pkg_pacman_build_date {
	#	grep "^Build Date " "${TMP_FOLDER}/pacman_pkg_cache.txt" | cut -f2 -d:
	local build_date
	local formatted_date

	if build_date=$(grep -oP 'Build Date\s*:\s*\K.*' "${TMP_FOLDER}/pacman_pkg_cache.txt") && [[ -n "$build_date" ]]; then
		formatted_date=$(date -d "$build_date" "+%a %b %d %H:%M:%S %Y" | LC_TIME=$LANG sed 's/^\([a-zA-Z]\)/\u\1/')
		echo "$formatted_date"
	fi
}
export -f sh_pkg_pacman_build_date

function sh_run_pamac_remove {
	packages_to_remove=$(LC_ALL=C timeout 10s pamac remove -odc "$*" | awk '/^  / { print $1 }')
	pamac-installer --remove "$@" $packages_to_remove &
	PID="$!"
	if [[ -z "$PID" ]]; then
		exit
	fi

	CONTADOR=0
	while [ $CONTADOR -lt 100 ]; do
		if [ "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" != "" ]; then
			xsetprop -id="$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" --atom WM_TRANSIENT_FOR --value "$(wmctrl -p -l -x | grep Big-Store$ | cut -f1 -d" ")" -f 32x
			wmctrl -i -r "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" -b add,skip_pager,skip_taskbar
			wmctrl -i -r "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" -b toggle,modal
			break
		fi

		sleep 0.1
		((++CONTADOR))
	done
	wait
}
export -f sh_run_pamac_remove

function sh_update_cache_snap {
	folder_to_save_files="$HOME_FOLDER/snap_list_files/snap_list"
	file_to_save_cache="$HOME_FOLDER/snap.cache"
	file_to_save_cache_filtered="$HOME_FOLDER/snap_filtered.cache"
	path_snap_list_files="$HOME_FOLDER/snap_list_files/"
	SITE="https://api.snapcraft.io/api/v1/snaps/search?confinement=strict&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media&scope=wide:"
	URL="https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media,&scope=wide:&page="

	[[ -e "$file_to_save_cache" ]] && rm -f "$file_to_save_cache"
	[[ -e "$file_to_save_cache_filtered" ]] && rm -f "$file_to_save_cache_filtered"
	[[ -d "$path_snap_list_files" ]] && rm -R "$path_snap_list_files"
	mkdir -p "$path_snap_list_files"

	# Anotação com as opções possíveis para utilizar na API
	#https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=anon_download_url,architecture,channel,download_sha3_384,summary,description,binary_filesize,download_url,last_updated,package_name,prices,publisher,ratings_average,revision,snap_id,license,base,media,support_url,contact,title,content,version,origin,developer_id,develope>

	# Anotação com a busca por wps-2019-snap em cache
	# jq -r '._embedded."clickindex:package"[]| select( .package_name == "wps-2019-snap" )' $folder_to_save_files*

	# Lê na pagina inicial quantas paginas devem ser baixadas e salva o valor na variavel $number_of_pages
	#	echo "Baixando header: $SITE"
	notify-send --icon=big-store --app-name "$0" "$TITLE" "Baixando header: $SITE" --expire-time=2000
	number_of_pages="$(curl --silent --compressed --insecure --url "$SITE" | jq -r '._links.last' | sed 's|.*page=||g;s|"||g' | grep '[0-9]')"

	if ((number_of_pages)); then
		# Baixa os arquivos em paralelo
		parallel --gnu --jobs 100% \
			"curl --compressed --silent --insecure -s --url '${URL}{}' --continue-at - --output '${folder_to_save_files}{}'" ::: $(seq 1 $number_of_pages)

		# Filtra e processa os arquivos em paralelo
		parallel --gnu --jobs 100% \
			"jq -r '._embedded.\"clickindex:package\"[]| .title + \"|\" + .snap_id + \"|\" + .media[0].url + \"|\" + .summary + \"|\" + .version + \"|\" + .package_name + \"|\"' '${folder_to_save_files}{}' | sort -u >> '${file_to_save_cache}'" ::: $(seq 1 $number_of_pages)
		# Aguarda o processamento
		wait
		grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/snap_list.txt "$file_to_save_cache" >"$file_to_save_cache_filtered"
	fi

	#	if (( number_of_pages )); then
	#		# Inicia o download em paralelo de todas as paginas
	#		for ((page=1; page<=number_of_pages; page++)); do
	#			echo "Baixando arquivo ${folder_to_save_files}${page}"
	#			notify-send --icon=big-store --app-name "$0" "$TITLE" "Baixando arquivo ${folder_to_save_files}${page}" --expire-time=2000
	#			curl --compressed --silent --url "$URL$page" > "${folder_to_save_files}${page}" &
	#			curl --compressed --silent --insecure -s --url "$URL$page" --continue-at - --output "${folder_to_save_files}${page}" &
	#		done

	#		# Aguarda o download de todos os arquivos
	#		wait

	#	    # Filtra o resultado dos arquivos e cria um arquivo de cache que será utilizado nas buscas
	#		jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' "$folder_to_save_files*" |
	#			sort -u >"$file_to_save_cache"
	#		for ((page=1; page<=number_of_pages; page++)); do
	#			echo "Processando jq página $page/$number_of_pages"
	#			notify-send --icon=big-store --app-name "$0" "$TITLE" "Processando jq página $page/$number_of_pages" --expire-time=2000
	#			jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' "${folder_to_save_files}${page}" |
	#				sort -u >> "$file_to_save_cache" &
	#		done

	#		# Aguarda o processamento do jq
	#		wait
	#	    grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/snap_list.txt "$file_to_save_cache" >"$file_to_save_cache_filtered"
	#	fi
}
export -f sh_update_cache_snap

function sh_update_cache_flatpak {
	# Defina os caminhos dos arquivos
	local LIST_FILE="/usr/share/bigbashview/bcc/apps/big-store/list/flatpak_list.txt"
	local CACHE_FILE="$HOME_FOLDER/flatpak.cache"
	local FILTERED_CACHE_FILE="$HOME_FOLDER/flatpak_filtered.cache"

	[[ -e "$CACHE_FILE" ]] && rm -f "$CACHE_FILE"

	# Realiza a busca de pacotes Flatpak, filtra e armazena no arquivo de cache
	#	flatpak search --arch x86_64 "" | sed '/\t/s//|/; /\t/s//|/; /\t/s//|/; /\t/s//|/; /\t/s//|/; /$/s//|/' | grep '|stable|' | rev | uniq --skip-fields=2 | rev >"$HOME/.bigstore/flatpak.cache"
	#	flatpak search --arch x86_64 "" | awk -F'\t' '{ print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"}' | grep '|stable|' | sort -u >"$CACHE_FILE"
	#   flatpak search --arch x86_64 "" |
	#        sed '/\t/s//|/g' |
	#        grep '|stable|' |
	#        rev |
	#        uniq --skip-fields=2 |
	#        rev >"$CACHE_FILE"

	# Realiza a busca usando flatpak search e filtra as informações necessárias
	flatpak search --arch x86_64 "" | sed '/\t/s//|/; /\t/s//|/; /\t/s//|/; /\t/s//|/; /\t/s//|/; /$/s//|/' |
		# Filtra apenas as linhas que contêm '|stable|'
		grep '|stable|' |
		# Inverte a ordem dos campos, removendo a segunda coluna duplicada
		rev | uniq --skip-fields=2 | rev |
		# Utiliza o parallel para escrever o resultado no arquivo
		parallel --gnu --jobs 100% "echo {} >> '$CACHE_FILE'"
	wait

	#	for i in $(LC_ALL=C flatpak update | grep "^ [1-9]" | awk '{print $2}'); do
	#		sed -i "s/|${i}.*/&update|/" "$CACHE_FILE"
	#	done

	# Executa o comando flatpak update para listar atualizações disponíveis
	# Filtra as linhas que começam com um espaço seguido por um dígito de 1 a 9 (indicando um pacote atualizável)
	# Extrai o nome do pacote (segundo campo) das linhas filtradas
	LC_ALL=C flatpak update | grep "^ [1-9]" | awk '{print $2}' | parallel --gnu --jobs 100% \
		"sed -i 's/|{}.*$/&update|/' '$CACHE_FILE'"
	wait
	#Realize a busca e filtragem de pacotes Flatpak
	grep -Fwf "$LIST_FILE" "$CACHE_FILE" >"$FILTERED_CACHE_FILE"
}
export -f sh_update_cache_flatpak

function sh_update_cache_complete {
	[[ ! -d "$HOME_FOLDER" ]] && mkdir -p "$HOME_FOLDER"
	[[ -e "/usr/lib/libpamac-flatpak.so" ]] && sh_update_cache_flatpak
	[[ -e "/usr/lib/libpamac-snap.so" ]] && sh_update_cache_snap
}
export -f sh_update_cache_complete

function sh_run_pacman_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pacman_mirror

function sh_snap_clean {
	if [ "$(snap get system refresh.retain)" != "2" ]; then
		snap set system refresh.retain=2
	fi

	OIFS=$IFS
	IFS=$'\n'

	for i in $(snap list --all | awk '/disabled/{print "snap remove", $1, "--revision", $3}'); do
		IFS=$OIFS
		$i
		IFS=$'\n'
	done
	IFS=$OIFS
}
export -f sh_snap_clean

function sh_snap_enable {
	systemctl start snapd
	systemctl enable snapd
	systemctl start apparmor
	systemctl enable apparmor
}
export -f sh_snap_enable

function sh_run_pamac_installer {
	local action="$1"
	local package="$2"
	local options="$3"

	local LangFilter="${LANG%%.*}"
	local LangFilterLowercase="${LangFilter,,}"
	local LangClean="${LangFilterLowercase%%_*}"
	local LangCountry="${LangFilterLowercase#*_}"
	if [[ -z "$package" ]]; then
		package=$action
	fi

	#	AutoAddLangPkg="$(pacman -Ssq $1.*$LangClean.* | grep -m1 [_-]$LangCountry)"
	AutoAddLangPkg="$(pacman -Ssq $package-.18.*$LangClean.* | grep -m1 "[_-]$LangCountry")"
	pamac-installer $@ $AutoAddLangPkg &
	PID="$!"

	if [[ -z "$PID" ]]; then
		exit
	fi

	CONTADOR=0
	while [ $CONTADOR -lt 100 ]; do
		if [ "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" != "" ]; then
			xsetprop -id="$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" --atom WM_TRANSIENT_FOR --value "$(wmctrl -p -l -x | grep Big-Store$ | cut -f1 -d" ")" -f 32x
			wmctrl -i -r "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" -b add,skip_pager,skip_taskbar
			wmctrl -i -r "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" -b toggle,modal
			break
		fi

		sleep 0.1
		((++CONTADOR))
	done
	wait
}
export -f sh_run_pamac_installer

function sh_run_pamac_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pamac_mirror

# qua 23 ago 2023 19:20:09 -04
function sh_pkg_flatpak_version {
	[[ -e "$HOME_FOLDER/flatpak-verification-fault" ]] && rm -f "$HOME_FOLDER/flatpak-verification-fault"
	if ! grep -i "$1|" "$HOME_FOLDER/flatpak.cache" | cut -f4 -d"|"; then
		echo "$1" >"$HOME_FOLDER/flatpak-verification-fault"
	fi
}
export -f sh_pkg_flatpak_version

# qua 23 ago 2023 19:20:09 -04
function sh_pkg_flatpak_update {
	grep -i "$1|" "$HOME_FOLDER/flatpak.cache" | cut -f6 -d"|"
}
export -f sh_pkg_flatpak_update

# qua 23 ago 2023 19:20:09 -04
function sh_pkg_flatpak_verify {
	echo "$1" >"$HOME_FOLDER/flatpak-verification-fault"
}
export -f sh_pkg_flatpak_verify

#qua 23 ago 2023 19:40:41 -04
function sh_load_main {
	local pacote="$2"
	local paths
	declare -g msgNenhumParam=$"Nenhum pacote passado como parâmetro"
	declare -g msgDownload=$"Baixando pacotes novos da base de dados do servidor"

	echo "$msgDownload"
	pacman -Fy >/dev/null 2>&-

	if [[ -n "$pacote" ]]; then
		case $1 in
		pkg_not_installed)
			pacman -Flq "$pacote" | sed 's|^|/|'
			;;
		pkg_installed)
			pacman -Qk "$pacote"
			pacman -Qlq "$pacote"
			;;
		pkg_installed_flatpak)
			echo "Folder base: $(flatpak info --show-location "$pacote")"
			find "$(flatpak info --show-location "$pacote")" | sed "s|$(flatpak info --show-location "$pacote")||g"
			;;
		esac
	else
		echo "$msgNenhumParam"
	fi
}
export -f sh_load_main

# qua 23 ago 2023 20:37:16 -04
function sh_this_package_update {
	pacman -Qu "$1" 2>/dev/null | awk '{print $NF}'
}
export -f sh_this_package_update

function sh_main {
	local execute_app="$1"

	if test $# -ge 1; then
		shift
		eval "$execute_app"
	fi
	#  return
}

#sh_debug
#sh_main "$@"
