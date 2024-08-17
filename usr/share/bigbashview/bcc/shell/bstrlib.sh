#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2317,SC2143
#shellcheck source=/dev/null

#  bstrlib.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2023/08/11
#  Altered: 2024/08/17
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

[[ -n "$LIB_BSTRLIB_SH" ]] && return
LIB_BSTRLIB_SH=1

APP="${0##*/}"
_DATE_ALTERED_="17-08-2024 - 02:56"
_VERSION_="1.0.0-20240817"
_BSTRLIB_VERSION_="${_VERSION_} - ${_DATE_ALTERED_}"
_UPDATED_="${_DATE_ALTERED_}"
#
export BOOTLOG="/tmp/big-store-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
export HOME_FOLDER="$HOME/.big-store"
export TMP_FOLDER="/tmp/big-store-$USER"
export INI_FILE_BIG_STORE="$HOME_FOLDER/big-store.ini"
export FILE_SUMMARY_JSON="/usr/share/bigbashview/bcc/apps/big-store/json/summary.json"
export FILE_SUMMARY_JSON_CUSTOM="$HOME_FOLDER/summary-custom.json"
export FILE_PACKAGE_JSON="/usr/share/bigbashview/bcc/apps/big-store/json/packages-meta-v1.json"
export FILE_PACKAGE_JSON_CUSTOM="$HOME_FOLDER/packages-meta-v1.json"
unset GREP_OPTIONS
#
#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store

export snap_cache_file="$HOME_FOLDER/snap.cache"
export snap_cache_filtered_file="$HOME_FOLDER/snap_filtered.cache"
export flatpak_cache_file="$HOME_FOLDER/flatpak.json"
export flatpak_cache_filtered_file="$HOME_FOLDER/flatpak_filtered.json"
export cacheFile="$flatpak_cache_file"

declare -g Programas_AUR=$"Programas AUR"
declare -g Programas_Flatpak=$"Programas Flatpak"
declare -g Programas_Nativos=$"Programas Nativos"
declare -g flatpak_versao=$"Versão: "
declare -g flatpak_pacote=$"Pacote: "
declare -g flatpak_nao_informada=$"Não informada"

declare -g Instalar_text=$"Instalar"
declare -g Remover_text=$"Remover"
declare -g Atualizar_text=$"Atualizar"

declare -g Button_Atualizar=$"Atualizar"
declare -g Button_Executar=$"Executar"
declare -g Button_Remover=$"Remover"
declare -g Button_Instalar=$"Instalar"
declare -g Button_Fechar=$"Fechar"
declare -g Button_Cancelar=$"Cancelar"
declare -g Versao=$"Versão: "
declare -g Pacote=$"Pacote: "
declare -g Versao_disponivel=$"Versão disponível:"
declare -g Repositorio=$"Repositório:"
declare -g Ramo=$"Ramo:"
declare -g Nao_informada=$"Não informada"
declare -g Programas_Flatpak=$"Programas Flatpak"

declare -gA PKG_FLATPAK
declare -gA PKG_TRANSLATE_DESC
export PKG_TRANSLATE_DESC
# Arquivo para armazenar o valor da variável 'static'
export static_file="$TMP_FOLDER/sh_search_flatpak.txt"

#######################################################################################################################

# ter 03 out 2023 02:41:00 -04
function sh_write_json_summary_sh {
	local name="$1"
	local version="$2"
	local status="$3"
	local size="$4"
	local description="$5"
	local lang="$6"
	local icon="$7"
	local tmp="$TMP_FOLDER/tmp.json"

	# Verifique se o arquivo JSON existe e, se não, crie-o com um objeto vazio
	if [ ! -f $FILE_SUMMARY_JSON ]; then
		echo '{}' >$FILE_SUMMARY_JSON
	fi
	echo '{}' >$tmp

	# Verifique se o objeto já existe no JSON
	if jq --arg name "$name" 'has($name)' $FILE_SUMMARY_JSON | grep -q 'true'; then
		# O objeto já existe, então atualize-o
		jq --arg name "$name" \
			--arg version "$version" \
			--arg size "$size" \
			--arg status "$status" \
			--arg lang "$lang" \
			--arg icon "$icon" \
			--arg description "$description" \
			'.[$name] |= {
               "name": $name,
               "version": $version,
               "size": $size,
               "status": $status,
               "icon": $icon,
               "description": (.description + { ($lang): $description })
            }' $FILE_SUMMARY_JSON >$tmp
	else
		# O objeto não existe, então crie-o
		new_obj="{
            \"name\": \"$name\",
            \"version\": \"$version\",
            \"size\": \"$size\",
            \"status\": \"$status\",
            \"icon\": \"$icon\",
            \"description\": {
                \"$lang\": \"$description\"
            }
        }"
		jq --argjson new_obj "$new_obj" '. += { ($new_obj.name): $new_obj }' $FILE_SUMMARY_JSON >$tmp
	fi

	# Mova o arquivo temporário de volta para o arquivo original
	mv "$tmp" "$FILE_SUMMARY_JSON"
}
export -f sh_write_json_summary_sh

#######################################################################################################################

# qua 04 out 2023 01:46:36 -04
function sh_write_json_summary_go {
	local name="$1"
	local version="$2"
	local status="$3"
	local size="$4"
	local description="$5"
	local lang="$6"
	local icon="$7"

	# Transformar em minúscula
	id_name="${name,,}"
	# Substituir espaços por hifens
	id_name="${id_name// /-}"
	# Substituir pontos por hifens
	id_name="${id_name//./-}"
	# Substituir /asteristico por hifens
	id_name="${id_name//\/\*/--}"
	description="${description//\/\*/--}"
	big-jq '-C' "$FILE_SUMMARY_JSON_CUSTOM" "$id_name" "$name" "$version" "$status" "$size" "$summary" "$lang" "$icon"
}
export -f sh_write_json_summary_go

# sex 06 out 2023 21:28:47 -04
function sh_write_json_summary_jq {
	local name="$1"
	local version="$2"
	local status="$3"
	local size="$4"
	local description="$5"
	local lang="$6"
	local icon="$7"

	# Transformar em minúscula
	id_name="${name,,}"
	# Substituir espaços por hifens
	id_name="${id_name// /-}"
	# Substituir pontos por hifens
	id_name="${id_name//./-}"
	# Substituir /asteristico por hifens
	id_name="${id_name//\/\*/--}"
	description="${description//\/\*/--}"

	jq \
		--arg name "$id_name" \
		--arg lang "$lang" \
		--arg newDescription "$description" \
		'.[$id_name].summary[$lang] = $newDescription' "$FILE_SUMMARY_JSON_CUSTOM" >tmp.json

	mv tmp.json "$FILE_SUMMARY_JSON_CUSTOM"
}
export -f sh_write_json_summary_jq

#######################################################################################################################

# sex 06 out 2023 21:28:47 -04
function sh_seek_json_summary_jq {
	local jsonFile="$1"
	local id_name="$2"
	local lang="$3"
	local result
	local retval=1

	# Verifique se o arquivo JSON existe e, se não, crie-o com um objeto vazio
	if [ ! -f $jsonFile ]; then
		echo '{}' >$jsonFile
	fi

	if result=$(jq -r --arg id_name "$id_name" --arg lang "$lang" '.[$id_name].summary[$lang]' "$jsonFile") && [[ "$result" != "null" ]]; then
		retval=0
	fi
	echo "$result"
	return $retval
}
export -f sh_seek_json_summary_jq

#######################################################################################################################

# qua 23 ago 2023 19:20:09 -04
function sh_get_XIVAStudio {
	release_description=$(lsb_release -sd)
	release_description=${release_description//\"/} # remove as aspas
	release_description=${release_description^^}    # Converte para maiúsculas
	if [[ "$release_description" == *"XIVA"* ]]; then
		return 0
	fi
	return 1
}
export -f sh_get_XIVAStudio

#######################################################################################################################

# qua 11 out 2023 13:24:51 -04
function sh_seek_json_icon_jq {
	local jsonFile="$1"
	local id_name="$2"
	local result
	local retval=1

	# Verifique se o arquivo JSON existe e, se não, crie-o com um objeto vazio
	if [ ! -f $jsonFile ]; then
		echo '{}' >$jsonFile
	fi

	if result=$(jq -r --arg id_name "$id_name" --arg lang "$lang" '.[$id_name].icon' "$jsonFile") && [[ "$result" != "null" ]]; then
		retval=0
	fi
	echo "$result"
	return $retval
}
export -f sh_seek_json_icon_jq

#######################################################################################################################

# qua 11 out 2023 13:24:51 -04
function sh_seek_json_icon_go {
	local jsonFile="$1"
	local id_name="$2"
	local result
	local retval=1

	if result=$(big-jq '-S' "$jsonFile" "$id_name.icon") && [[ "$result" != "null" ]]; then
		retval=0
	fi
	echo "$result"
	return $retval
}
export -f sh_seek_json_icon_go

#######################################################################################################################

# sex 06 out 2023 21:28:47 -04
function sh_seek_json_summary_go {
	local jsonFile="$1"
	local id_name="$2"
	local lang="$3"
	local result
	local retval=1

	if result=$(big-jq '-S' "$jsonFile" "$id_name.summary.$lang") && [[ "$result" != "null" ]]; then
		retval=0
	fi
	echo "$result"
	return $retval
}
export -f sh_seek_json_summary_go

#######################################################################################################################

function sh_change_pkg_id {
	local name="$1"
	# Transformar em minúscula
	id_name="${name,,}"
	# Substituir espaços por hifens
	id_name="${id_name// /-}"
	# Substituir pontos por hifens
	id_name="${id_name//./-}"
	# Substituir /asteristico por hifens
	id_name="${id_name//\/\*/--}"

	echo "$id_name"
}
export -f sh_change_pkg_id

#######################################################################################################################

# seg 02 out 2023 03:39:10 -04
function sh_translate_desc {
	local name="$1"
	local traducao_online="$2"
	local description="$3"
	local icon="$4"
	local updated=0
	local summary
	local result
	local lang
	local id_name

	lang=$(sh_get_language_without_utf8)
	[[ -z "$lang" ]] && lang=$(sh_get_lang_without_utf8)
	id_name=$(sh_change_pkg_id "$name")
	description="${description//\/\*/--}"
	summary="$description"

	if ((traducao_online)); then
		case "${lang^^}" in
		EN_US) ;;
		PT_BR)
			#			if ! result=$(sh_seek_json_summary_go "$FILE_SUMMARY_JSON" "$id_name" "$lang"); then
			if result=$(sh_seek_json_summary_go "$FILE_SUMMARY_JSON_CUSTOM" "$id_name" "$lang"); then
				echo "$result"
				return 0
			fi
			#			else
			#				echo "$result"
			#				return 0
			#			fi

			if summary=$(trans -no-auto -no-autocorrect -brief :"${lang/_/-}" "$description") && [[ -z "$summary" ]]; then
				summary="$description"
				updated=0
			else
				updated=1
			fi
			;;
		*)
			if result=$(sh_seek_json_summary_go "$FILE_SUMMARY_JSON_CUSTOM" "$id_name" "$lang"); then
				echo "$result"
				return 0
			fi

			if summary=$(trans -no-auto -no-autocorrect -brief :"${lang/_/-}" "$description") && [[ -z "$summary" ]]; then
				summary="$description"
				updated=0
			else
				updated=1
			fi
			;;
		esac
	fi

	if ((updated)); then #OK
		big-jq '-C' "$FILE_SUMMARY_JSON_CUSTOM" "$id_name" "$name" "$version" "$status" "$size" "$summary" "$lang" "$icon"
	fi
	echo "$summary"
	return "$((!updated))"
}
export -f sh_translate_desc

#######################################################################################################################
function sh_read_number_var() {
	local file="$1"
	local count=0

	if [[ -f $file ]]; then
		count=$(<"$file")
	fi
	echo $count
}
export -f sh_read_number_var

#######################################################################################################################

# Função para ler o valor da variável 'static' do arquivo
function read_static_var() {
	if [[ -f $static_file ]]; then
		static_var=$(<"$static_file")
	else
		static_var=0
	fi
	echo $static_var
}
export -f read_static_var

# Função para salvar o valor da variável 'static' no arquivo
function write_static_var() {
	echo "$static_var" >"$static_file"
}
export -f write_static_var

# Função que acessa e modifica a variável 'static'
function increment_static_var() {
	static_var=$(read_static_var)
	((++static_var))
	write_static_var
}
export -f increment_static_var

#######################################################################################################################

function sh_flatpak_installed_list {
	# Le os pacotes instalados em flatpak
	local FLATPAK_INSTALLED_LIST="|$(flatpak list | cut -f2 -d$'\t' | tr '\n' '|')"
	echo "$FLATPAK_INSTALLED_LIST"
}

#######################################################################################################################

function sh_seek_flatpak_parallel_filter() {
	local package="$1"
	local myarray
	local icon
	local id_name
	local pkg
	local description
	local summary
	local result
	local item
	local name
	local desc
	local id
	local version
	local branch
	local remote
	local count
	local -A ALL_PKG_FLATPAK=()

	id_name="$(sh_change_pkg_id "$package")"

	#	PKG_FLATPAK[PKG_NAME]="$(big-jq '-S' "$cacheFile" "$id_name.name")"
	#	PKG_FLATPAK[PKG_DESC]="$(big-jq '-S' "$cacheFile" "$id_name.description")"
	#	PKG_FLATPAK[PKG_ID]="$(big-jq '-S' "$cacheFile" "$id_name.id_name")"
	#	PKG_FLATPAK[PKG_VERSION]="$(big-jq '-S' "$cacheFile" "$id_name.version")"
	#	PKG_FLATPAK[PKG_STABLE]="$(big-jq '-S' "$cacheFile" "$id_name.branch")"
	#	PKG_FLATPAK[PKG_REMOTE]="$(big-jq '-S' "$cacheFile" "$id_name.remotes")"
	#	PKG_FLATPAK[PKG_UPDATE]=""
	#	PKG_FLATPAK[PKG_ICON]="$(big-jq '-S' "$cacheFile" "$id_name.icon")"
	#	mapfile -t -d'|' myarray < <(jq --arg id_name "$id_name" -r 'to_entries[] | select(.key | test("(?i).*" + $id_name + ".*")) | "\(.value.name)|\(.value.description)|\(.value.id_name)|\(.value.version)|\(.value.branch)|\(.value.remotes)|\(.value.icon)"' "$cacheFile")
	#	mapfile -t -d'|' myarray < <(jq --arg id_name "$id_name" -r 'to_entries[] | select(.key | test($id_name)) | "\(.value.name)|\(.value.description)|\(.value.id_name)|\(.value.version)|\(.value.branch)|\(.value.remotes)|\(.value.icon)"' "$cacheFile")
	#	result=$(jq --arg id_name "$id_name" -r 'to_entries[] | select(.key | test("(?i).*" + $id_name + ".*")) | "\(.key | gsub("[|]";""))|\(.value.name | gsub("[|]";""))|\(.value.description | gsub("[|]";""))|\(.value.id_name | gsub("[|]";""))|\(.value.version | gsub("[|]";""))|\(.value.branch | gsub("[|]";""))|\(.value.remotes | gsub("[|]";""))|\(.value.icon | gsub("[|]";""))"' "$cacheFile")
	#	result=$(jq --arg id_name "$id_name" -r 'to_entries[] | select(.key | test($id_name)) | "\(.value.name)|\(.value.description)|\(.value.id_name)|\(.value.version)|\(.value.branch)|\(.value.remotes)|\(.value.icon)"' "$cacheFile")
	#	result=$(jq --arg id_name "$id_name" -r 'to_entries[] | select(.key | test($id_name)) | "\(.value.name)|\(.value.description)|\(.value.id_name)|\(.value.version)|\(.value.branch)|\(.value.remotes)|\(.value.icon)"' "$cacheFile")

	# Usando jq para buscar e formatar a saída com busca insensível a maiúsculas/minúsculas e por parte da string
	if ((searchInDescription)) && ! ((flatpak_search_category)); then
		result=$(jq --arg name "$id_name" -r '
				.[] |
				select(
				(.name | ascii_downcase | contains($name | ascii_downcase)) or
				(.description | ascii_downcase | contains($name | ascii_downcase)) or
				(.id_name | ascii_downcase | contains($name | ascii_downcase)) or
				(.version | ascii_downcase | contains($name | ascii_downcase)) or
				(.branch | ascii_downcase | contains($name | ascii_downcase)) or
				(.remotes | ascii_downcase | contains($name | ascii_downcase))
				) |
				"\(.name)|\(.description)|\(.id_name)|\(.version)|\(.branch)|\(.remotes)|\(.icon)"
			' "$cacheFile")
	else
		result=$(jq --arg name "$id_name" -r '
			  .[] |
			  select(.name | ascii_downcase | contains($name | ascii_downcase)) |
			  "\(.name)|\(.description)|\(.id_name)|\(.version)|\(.branch)|\(.remotes)|\(.icon)"
			' "$cacheFile")
	fi

	# Nao achou? Retorna false
	[[ -z "$result" ]] || [[ "${#result}" -eq 0 ]] && return

	# Usando mapfile para ler o resultado em um array
	#		mapfile -t -d'|' myarray <<< "$result"
	mapfile -t myarray <<<"$result"

	for item in "${myarray[@]}"; do
		increment_static_var
		# Separar os valores usando o delimitador '|'
		IFS='|' read -r name desc id version branch remote icon <<<"$item"
		[[ -z "$name" ]] || [[ "$name" = '' ]] || [[ "$name" = '0' ]] && continue
		((++count))

		# Preencher o array associativo com os valores
		PKG_FLATPAK[PKG_NAME]="$name"
		PKG_FLATPAK[PKG_DESC]="$desc"
		PKG_FLATPAK[PKG_ID]="$id"
		PKG_FLATPAK[PKG_VERSION]="$version"
		PKG_FLATPAK[PKG_BRANCH]="$branch"
		PKG_FLATPAK[PKG_REMOTE]="$remote"
		PKG_FLATPAK[PKG_ICON]="$icon"
		PKG_FLATPAK[PKG_UPDATE]=""

		pkg="${PKG_FLATPAK[PKG_ID]}"
		description="${PKG_FLATPAK[PKG_DESC]}"
		summary="$description"

		# Seleciona o arquivo xml para filtrar os dados
		PKG_FLATPAK[PKG_XML_APPSTREAM]="/var/lib/flatpak/appstream/${PKG_FLATPAK[PKG_REMOTE]}/x86_64/active/appstream.xml"
		if [[ -z "${PKG_FLATPAK[PKG_VERSION]}" ]]; then
			PKG_FLATPAK[PKG_VERSION]="$flatpak_nao_informada"
		fi
		summary="$(sh_translate_desc "$pkg" "$traducao_online" "$description" "${PKG_FLATPAK[PKG_ICON]}")"
		#		icon=$(sh_seek_json_icon_go "$FILE_SUMMARY_JSON" "$(sh_change_pkg_id "$pkg")")
		PKG_FLATPAK[PKG_DESC]="$summary"
		PKG_FLATPAK[PKG_ICON]="$icon"
		if ! test -e "${PKG_FLATPAK[PKG_ICON]}"; then
			PKG_FLATPAK[PKG_ICON]="/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/${PKG_FLATPAK[PKG_ID]}.png"
			if ! test -e "${PKG_FLATPAK[PKG_ICON]}"; then
				PKG_FLATPAK[PKG_ICON]="/var/lib/flatpak/appstream/flathub/x86_64/active/icons/128x128/${PKG_FLATPAK[PKG_ID]}.png"
				if ! test -e "${PKG_FLATPAK[PKG_ICON]}"; then
					PKG_FLATPAK[PKG_ICON]=""
				fi
			fi
		fi
		ALL_PKG_FLATPAK+=(["$name"]="${PKG_FLATPAK[PKG_NAME]}|${PKG_FLATPAK[PKG_DESC]}|${PKG_FLATPAK[PKG_ID]}|${PKG_FLATPAK[PKG_VERSION]}|${PKG_FLATPAK[PKG_BRANCH]}|${PKG_FLATPAK[PKG_REMOTE]}|${PKG_FLATPAK[PKG_ICON]}|${PKG_FLATPAK[PKG_UPDATE]}|${PKG_FLATPAK[PKG_XML_APPSTREAM]}")
	done
	[[ -z "${ALL_PKG_FLATPAK[@]}" ]] && return
	((count)) && echo "$(declare -p ALL_PKG_FLATPAK)"
}

#######################################################################################################################

function sh_search_flatpak() {
	local search="$*"
	local traducao_online
	local -i LIMITE
	local -i COUNT
	local i

	[[ -e "$TMP_FOLDER/flatpak_number.html" ]] && rm -f "$TMP_FOLDER/flatpak_number.html"
	[[ -e "$TMP_FOLDER/flatpak.html" ]] && rm -f "$TMP_FOLDER/flatpak.html"
	[[ -e "$TMP_FOLDER/flatpak_build.html" ]] && rm -f "$TMP_FOLDER/flatpak_build.html"
	[[ -e "$static_file" ]] && rm -f "$static_file"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	searchInDescription=0
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Le os pacotes instalados em flatpak
	FLATPAK_INSTALLED_LIST=$(sh_flatpak_installed_list)

	# Inicia uma função para possibilitar o uso em modo assíncrono
	function flatpak_parallel_filter() {
		local package="$1"
		local myarray
		local icon
		local id_name
		local COUNT
		local -A ALL_PKG_FLATPAK=()

		id_name="$(sh_change_pkg_id "$package")"
		if ALL_PKG_FLATPAK="$(sh_seek_flatpak_parallel_filter "$id_name")" && [[ -z "${ALL_PKG_FLATPAK[@]}" ]]; then
			return 1
		fi
		# Avalia a definição para recriar o array associativo
		eval "$ALL_PKG_FLATPAK"
		[[ "${#ALL_PKG_FLATPAK[@]}" -eq 0 ]] && return 1

		# Improve order of packages
		PKG_NAME_CLEAN="${search% *}"

		for key in "${!ALL_PKG_FLATPAK[@]}"; do
			pkg_name="$key"
			#			[[ "$pkg_name" = '0' ]] && continue
			pkg_desc="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 2)"
			pkg_id="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 3)"
			pkg_version="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 4)"
			pkg_branch="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 5)"
			pkg_remote="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 6)"
			pkg_icon="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 7)"
			pkg_update="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 8)"
			pkg_xml_appstream="$(sh_splitarray "${ALL_PKG_FLATPAK[$key]}" 9)"

			# Verify if package are installed
			if [[ "$FLATPAK_INSTALLED_LIST" == *"|${pkg_id}|"* ]]; then
				if [ -n "$(tr -d '\n' <<<"${pkg_update}")" ]; then
					pkg_installed="$Atualizar_text"
					div_flatpak_installed="flatpak_upgradable"
					pkg_order="FlatpakP1"
				else
					pkg_installed="$Remover_text"
					div_flatpak_installed="flatpak_installed"
					pkg_order="FlatpakP1"
				fi
			else
				pkg_installed="$Instalar_text"
				div_flatpak_installed="flatpak_not_installed"

				if grep -q -i -m1 "$PKG_NAME_CLEAN" <<<"${pkg_id}"; then
					pkg_order="FlatpakP2"
				elif grep -q -i -m1 "$PKG_NAME_CLEAN" <<<"${pkg_id}"; then
					pkg_order="FlatpakP3"
				else
					pkg_order="FlatpakP4"
				fi
			fi

			summary="${pkg_desc}"
			pkg_summary_encoded=$(printf '%s' "$summary" | jq -sRr @uri)

			# If all fail, use generic icon
			if [[ -z "${pkg_icon}" || -n "$(LC_ALL=C grep -i -m1 -e 'type=' -e '<description>' <<<"${pkg_icon}")" ]]; then
				pkg_name_encoded=$(printf '%s' "${pkg_name}" | jq -sRr @uri)
				cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
					<a onclick="disableBody();" href='view_flatpak.sh.htm?pkg_summary=$pkg_summary_encoded&pkg_name=${pkg_name}'>
					<div class="col s12 m6 l3" id="${pkg_order}">
					<div class="showapp">
					<div id="flatpak_icon">
					<div class="icon_middle">
					<div class="icon_middle">
					<div class="avatar_flatpak">
					${pkg_name:0:3}
					</div>
					</div>
					</div>
					<div id="flatpak_name">
					${pkg_name}
					<div id="version">
					${pkg_version}
					</div>
					</div>
					</div>
					<div id="box_flatpak_desc">
					<div id="flatpak_desc">
					${pkg_desc}
					</div>
					</div>
					<div id="${div_flatpak_installed}">
					${pkg_installed}
					</div>
					</a>
					</div>
					</div>
				EOF
			else
				pkg_name_encoded=$(printf '%s' "${pkg_id}" | jq -sRr @uri)
				cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
					<a onclick="disableBody();" href='view_flatpak.sh.htm?pkg_summary=$pkg_summary_encoded&pkg_name=${pkg_id}'>
					<div class="col s12 m6 l3" id="${pkg_order}">
					<div class="showapp">
					<div id="flatpak_icon">
					<div class="icon_middle">
					<img class="icon" loading="lazy" src="${pkg_icon}">
					</div>
					<div id="flatpak_name">
					${pkg_name}
					<div id="version">
					${pkg_version}
					</div>
					</div>
					</div>
					<div id="box_flatpak_desc">
					<div id="flatpak_desc">
					${pkg_desc}
					</div>
					</div>
					<div id="${div_flatpak_installed}">
					${pkg_installed}
					</div>
					</a>
					</div>
					</div>
				EOF
			fi
		done
	}

	if [[ -z "$resultFilter_checkbox" ]]; then
		cacheFile="$flatpak_cache_file"
	else
		cacheFile="$flatpak_cache_filtered_file"
	fi

	LIMITE=60
	COUNT=0

	for i in ${search[*]}; do
		if result="$(grep -i -e "$i" "$cacheFile")" && [[ -n "$result" ]]; then
			((++COUNT))
			flatpak_parallel_filter "$i" &
		fi
		if ((COUNT >= LIMITE)); then
			break
		fi
	done

	# Aguarda todos os resultados antes de exibir para o usuário
	wait

	COUNT="$(read_static_var)"

	if ((COUNT)); then
		echo "$COUNT" >"$TMP_FOLDER/flatpak_number.html"
		cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
			<script>runAvatarFlatpak();\$(document).ready(function () {\$("#box_flatpak").show();});</script>
			<script>\$(document).ready(function() {\$("#box_flatpak").show();});</script>
			<script>document.getElementById("flatpak_icon_loading").innerHTML = ""; runAvatarFlatpak();</script>
		EOF
	else
		echo "0" >"$TMP_FOLDER/flatpak_number.html"
		cat >>"$TMP_FOLDER/flatpak_build.html" <<-EOF
			<script>document.getElementById("flatpak_icon_loading").innerHTML = ""; runAvatarFlatpak();</script>
		EOF
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/flatpak_build.html" "$TMP_FOLDER/flatpak.html"
}
export -f sh_search_flatpak

#######################################################################################################################

function sh_search_snap() {
	local search="$*"
	local traducao_online

	[[ -e "$TMP_FOLDER/snap.html" ]] && rm -f "$TMP_FOLDER/snap.html"
	[[ -e "$TMP_FOLDER/snap_number.html" ]] && rm -f "$TMP_FOLDER/snap_number.html"
	[[ -e "$TMP_FOLDER/snap_build.html" ]] && rm -f "$TMP_FOLDER/snap_build.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	searchInDescription=0
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Lê os pacotes instalados em snap
	SNAP_INSTALLED_LIST="|$(awk 'NR>1 {printf "%s|", $1} END {printf "\b\n"}' <(snap list))"

	# Inicia uma função para possibilitar o uso em modo assíncrono
	function snap_parallel_filter() {
		mapfile -t -d"|" myarray <<<"$1"
		PKG_NAME="${myarray[0]}"
		PKG_ID="${myarray[1]}"
		PKG_ICON="${myarray[2]}"
		PKG_DESC="${myarray[3]}"
		PKG_VERSION="${myarray[4]}"
		PKG_CMD="${myarray[5]}"

		pkg="$PKG_NAME"
		description="$PKG_DESC"
		summary="$description"
		summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
		PKG_DESC="$summary"

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

	if [[ -z "$resultFilter_checkbox" ]]; then
		cacheFile="$snap_cache_file"
	else
		cacheFile="$snap_cache_filtered_file"
	fi

	local COUNT=0
	local LIMITE=60

	for i in ${search[@]}; do
		if ! ((snap_search_category)); then
			# Se NÃO é para buscar na descrição
			if ! ((searchInDescription)); then
				# Construir a expressão regular no primeiro campo do arquivo de cache
				i="^[^|]*${i}[^|]*\|"
			fi
		fi
		result="$(grep -i -E "$i" "$cacheFile")"

		if [[ -n "$result" ]]; then
			while IFS= read -r line; do
				((++COUNT))
				snap_parallel_filter "$line" &
				if [ "$COUNT" = "$LIMITE" ]; then
					break
				fi
			done <<<"$result"
		fi
	done

	#Aguarda todos os resultados antes de exibir para o usuário
	wait

	if ((COUNT)); then
		echo "$COUNT" >"$TMP_FOLDER/snap_number.html"
		cat >>"$TMP_FOLDER/snap_build.html" <<-EOF
			<script>runAvatarSnap();\$(document).ready(function () {\$("#box_snap").show();});</script>
			<script>\$(document).ready(function() {\$("#box_snap").show();});</script>
			<script>document.getElementById("snap_icon_loading").innerHTML = ""; runAvatarSnap();</script>
		EOF
	else
		echo "0" >"$TMP_FOLDER/snap_number.html"
		cat >>"$TMP_FOLDER/snap_build.html" <<-EOF
			<script>document.getElementById("snap_icon_loading").innerHTML = ""; runAvatarSnap();</script>
		EOF
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/snap_build.html" "$TMP_FOLDER/snap.html"
}
export -f sh_search_snap

#######################################################################################################################

function sh_search_aur_category {
	local search="$*"
	local pkg=""
	local version=""
	local description=""
	local not_installed=""
	local idaur=""
	local button=""
	local count=0
	local icon=""
	local line
	local traducao_online
	local searchFilter_checkbox
	local searchInDescription=0

	[[ -e "$TMP_FOLDER/aur.html" ]] && rm -f "$TMP_FOLDER/aur.html"
	[[ -e "$TMP_FOLDER/aur_build.html" ]] && rm -f "$TMP_FOLDER/aur_build.html"
	[[ -e "$TMP_FOLDER/aur_number.html" ]] && rm -f "$TMP_FOLDER/aur_number.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	while IFS= read -r line; do
		if [[ -z "$line" ]]; then
			if [[ -n "$pkg" || -n "$version" || -n "$description" || -n "$idaur" || -n "$button" ]]; then
				icon=""
				if [[ -e "icons/$pkg.png" ]]; then
					icon="<img class=\"icon\" src=\"icons/$pkg.png\">"
				else
					icon="<div class=avatar_aur>${pkg:0:3}</div>"
				fi
				{
					echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=$pkg\">"
					echo "<div class=\"col s12 m6 l3\" id=$idaur>"
					echo "<div class=\"showapp\">"
					echo "<div id=aur_icon><div class=icon_middle>$icon</div>"
					echo "<div id=aur_name><div id=limit_title_name>$pkg</div>"
					echo "<div id=version>$version</div></div></div>"
					echo "<div id=box_aur_desc><div id=aur_desc>$description</div></div>"
					echo "$button"
				} >>"$TMP_FOLDER/aur_build.html"
				((++count))
			fi

			pkg=""
			version=""
			description=""
			not_installed=""
			idaur=""
			button=""
		elif [[ $line =~ ^Name ]]; then
			pkg="${line#*: }"
			if ! sh_package_is_installed "$pkg"; then
				idaur="AurP2"
				button="<div id=aur_not_installed>Instalar</div></a></div></div>"
			else
				idaur="AurP1"
				button="<div id=aur_installed>Remover</div></a></div></div>"
			fi
		elif [[ $line =~ ^Version ]]; then
			version="${line#Version*: }"
		elif [[ $line =~ ^Description ]]; then
			description="${line#Description*: }"
			summary="$description"
			summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
			description="$summary"
		fi
	done < <(LC_ALL=C paru -Sia $search --limit 60 --sortby popularity --topdown 2>/dev/null)
	#	done < <(LANGUAGE=C yay -Sia $search --topdown)

	if ((count)); then
		echo "$count" >"$TMP_FOLDER/aur_number.html"
		echo "<script>\$(document).ready(function() {\$(\"#box_aur\").show();});</script>" >>"$TMP_FOLDER/aur_build.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"

		# Move temporary HTML file to final location
		mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
	fi
}
export -f sh_search_aur_category

#######################################################################################################################

function sh_search_aurOLD {
	local search="$*"
	local n=1
	local count=0
	local cmd
	local pacote
	local regex=""
	local traducao_online
	local searchFilter_checkbox
	local searchInDescription=0
	local site='https://aur.archlinux.org/packages-meta-v1.json.gz'

	[[ -e "$TMP_FOLDER/aur.html" ]] && rm -f "$TMP_FOLDER/aur.html"
	[[ -e "$TMP_FOLDER/aur_build.html" ]] && rm -f "$TMP_FOLDER/aur_build.html"
	[[ -e "$TMP_FOLDER/aur_number.html" ]] && rm -f "$TMP_FOLDER/aur_number.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Loop para concatenar os nomes dos pacotes à regex
	for pacote in ${search[*]}; do
		if [[ -n "$regex" ]]; then
			regex+="|"
		fi
		if ((aur_search_category)); then
			regex+="$pacote$"
		else
			regex+="$pacote"
		fi
	done

	# Adiciona ^ no início para garantir que a correspondência seja feita no início da linha
	#	regex="^($regex)"
	regex="($regex)"

	if ! ((searchInDescription)); then
		#		json=$(LC_ALL=C big-pacman-to-json yay -Ssa --regex "$regex" --sortby popularity --topdown)
		#		json=$(LC_ALL=C big-pacman-to-json pacaur -Ssa --regex $regex)
		#		json=$(LC_ALL=C big-pacman-to-json paru -Ssa --regex $regex --limit 60 --sortby popularity --topdown)
		#		json=$(LC_ALL=C big-pacman-to-json package-query -Ss --aur $regex)
		json=$(LC_ALL=C big-pacman-to-json paru --aur -Qs $regex --limit 60 --sortby popularity --topdown)
	else
		#		json=$(LC_ALL=C big-pacman-to-json yay -Ssa --regex "$regex" --sortby popularity --searchby name-desc)
		#		json=$(LC_ALL=C big-pacman-to-json pacaur -Ssa --regex $regex)
		#		json=$(LC_ALL=C big-pacman-to-json paru -Ssa --regex $regex --limit 60 --sortby popularity --searchby name-desc)
		#		json=$(LC_ALL=C big-pacman-to-json package-query -Ss --aur $regex)
		json=$(LC_ALL=C big-pacman-to-json paru --aur -Qs $regex --limit 60 --sortby popularity --searchby name-desc --topdown)
	fi

	# Armazene o JSON em uma variável para evitar chamadas jq repetidas
	item_json=$(jq -c '.[]' <<<"$json")

	# Use um while loop para processar os itens JSON
	while IFS= read -r item; do
		#		name=$(jq -r '.name' <<<"$item")
		#		pkg=${name#aur/}
		#		description=$(jq -r '.description' <<<"$item")

		# Usando jq para extrair todos os valores em uma única linha, separados por vírgulas
		values=$(jq -r '[.name, .version, .size, .status, .Repo, .description] | @csv' <<<"$item")

		# Remove aspas duplas que o @csv adiciona
		values=${values//\"/}

		# Lê os valores em variáveis
		IFS=',' read -r name version size status Repo description <<<"$values"

		#		pkg=${name#aur/}
		#		if [[ $name == aur/* ]]; then
		pkg=${name#local/}

		if [[ $name == local/* ]]; then
			# Se NÃO é por categorias
			if ! ((aur_search_category)); then
				# Se NÃO é para buscar na descrição
				if ! ((searchInDescription)); then
					# Se a variável $search NÃO contiver a palavra $pkg
					if [[ ! "$pkg" =~ "$search" ]]; then
						continue
					fi
				fi
			fi

			#			version=$(jq -r '.version' <<<"$item")
			#			size=$(jq -r '.size' <<<"$item")
			#			status=$(jq -r '.status' <<<"$item")

			pkgicon=${pkg//-bin/}
			pkgicon=${pkgicon//-git/}
			pkgicon=${pkgicon//-beta/}
			title=${pkg//-/ }
			unset title_uppercase_first_letter

			for word in $title; do
				title_uppercase_first_letter+=" ${word^}"
			done

			if [[ "$status" == *"Installed"* ]]; then
				button="<div id=aur_installed>$Remover_text</div>"
				aur_priority="AurP1"
			else
				button="<div id=aur_not_installed>$Instalar_text</div>"
				if [[ "$search" =~ .*"$title".* ]]; then
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

			summary="$description"
			summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
			pkg_summary_encoded=$(printf '%s' "$summary" | jq -s -R -r @uri)

			{
				echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_summary=$pkg_summary_encoded&pkg_name=$pkg\">"
				echo "<div class=\"col s12 m6 l3\" id=$aur_priority>"
				echo "<div class=\"showapp\">"
				echo "<div id=aur_icon><div class=icon_middle>$icon</div>"
				echo "<div id=aur_name><div id=limit_title_name>$title_uppercase_first_letter</div>"
				echo "<div id=version>$version</div></div></div>"
				echo "<div id=box_aur_desc><div id=aur_desc>$summary</div></div>"
				echo "$button</a></div></div>"
			} >>"$TMP_FOLDER/aur_build.html"
			((++count))
		else
			continue
		fi
	done < <(echo "$item_json")

	if ((count)); then
		echo "$count" >"$TMP_FOLDER/aur_number.html"
		echo "<script>\$(document).ready(function() {\$(\"#box_aur\").show();});</script>" >>"$TMP_FOLDER/aur_build.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	else
		echo "0" >"$TMP_FOLDER/aur_number.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
}
export -f sh_search_aurOLD

#######################################################################################################################

function sh_search_aur() {
	local search="$*"
	local n=1
	local count=0
	local cmd
	local pacote
	local regex=""
	local traducao_online
	local searchFilter_checkbox
	local searchInDescription=0
	local site='https://aur.archlinux.org/packages-meta-v1.json.gz'
	local metapackage="$HOME_FOLDER/packages-meta-v1.json"
	local output_file="$TMP_FOLDER/filtered-results-aur.json"
	local item_json
	local separator="|"

	[[ -e "$TMP_FOLDER/aur.html" ]] && rm -f "$TMP_FOLDER/aur.html"
	[[ -e "$TMP_FOLDER/aur_build.html" ]] && rm -f "$TMP_FOLDER/aur_build.html"
	[[ -e "$TMP_FOLDER/aur_number.html" ]] && rm -f "$TMP_FOLDER/aur_number.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Loop para concatenar os nomes dos pacotes à regex
	for pacote in ${search[*]}; do
		if [[ -n "$regex" ]]; then
			regex+="|"
		fi
		if ((aur_search_category)); then
			regex+="$pacote$"
		else
			regex+="$pacote"
		fi
	done
	if ! ((aur_search_category)) && ((searchInDescription)); then
		regex="($regex)"
	else
		regex="^($regex)"
	fi

	if ! ((aur_search_category)); then
		if ((searchInDescription)); then
			json=$(big-search-aur -Ss ${search} --limit 60 --by-name-desc --raw --verbose)
		else
			json=$(big-search-aur -Ss ${search} --limit 60 --by-name --raw --verbose)
		fi
	else
		json=$(big-search-aur -Si ${search} --limit 60 --by-name --raw --verbose)
	fi

	mapfile -t item_json <<<"$json"

	# Itera sobre cada linha (pacote)
	for item in "${item_json[@]}"; do
		IFS="$separator" read -r name version description maintainer num_votes popularity url full_url pkgcount <<<"$item"
		pkg=${name#aur/}
		pkg=${name#local/}

		if [[ -n "$name" ]]; then
			# Se NÃO é por categorias
			if ! ((aur_search_category)); then
				# Se NÃO é para buscar na descrição
				if ! ((searchInDescription)); then
					# Se a variável $search NÃO contiver a palavra $pkg
					if [[ ! "$pkg" =~ "$search" ]]; then
						continue
					fi
				fi
			fi

			pkgicon=${pkg//-bin/}
			pkgicon=${pkgicon//-git/}
			pkgicon=${pkgicon//-beta/}
			title=${pkg//-/ }
			unset title_uppercase_first_letter

			for word in $title; do
				title_uppercase_first_letter+=" ${word^}"
			done

			#			if [[ "$status" == *"Installed"* ]]; then
			if [[ -n "$(pacman -Qs "^$name$")" ]]; then
				button="<div id=aur_installed>$Remover_text</div>"
				aur_priority="AurP1"
			else
				button="<div id=aur_not_installed>$Instalar_text</div>"
				if [[ "$search" =~ .*"$title".* ]]; then
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

			summary="$description"
			summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
			pkg_summary_encoded=$(printf '%s' "$summary" | jq -s -R -r @uri)

			{
				echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_summary=$pkg_summary_encoded&pkg_name=$pkg\">"
				echo "<div class=\"col s12 m6 l3\" id=$aur_priority>"
				echo "<div class=\"showapp\">"
				echo "<div id=aur_icon><div class=icon_middle>$icon</div>"
				echo "<div id=aur_name><div id=limit_title_name>$title_uppercase_first_letter</div>"
				echo "<div id=version>$version</div></div></div>"
				echo "<div id=box_aur_desc><div id=aur_desc>$summary</div></div>"
				echo "$button</a></div></div>"
			} >>"$TMP_FOLDER/aur_build.html"
			((++count))
		else
			continue
		fi
	done

	if ((count)); then
		echo "$count" >"$TMP_FOLDER/aur_number.html"
		echo "<script>\$(document).ready(function() {\$(\"#box_aur\").show();});</script>" >>"$TMP_FOLDER/aur_build.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	else
		echo "0" >"$TMP_FOLDER/aur_number.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
}
export -f sh_search_aur

#######################################################################################################################

function sh_search_aurSearch() {
	local search="$*"
	local n=1
	local count=0
	local cmd
	local pacote
	local regex=""
	local traducao_online
	local searchFilter_checkbox
	local searchInDescription=0
	local site='https://aur.archlinux.org/packages-meta-v1.json.gz'
	local metapackage="$HOME_FOLDER/packages-meta-v1.json"
	local output_file="$TMP_FOLDER/filtered-results-aur.json"
	local item_json

	[[ -e "$TMP_FOLDER/aur.html" ]] && rm -f "$TMP_FOLDER/aur.html"
	[[ -e "$TMP_FOLDER/aur_build.html" ]] && rm -f "$TMP_FOLDER/aur_build.html"
	[[ -e "$TMP_FOLDER/aur_number.html" ]] && rm -f "$TMP_FOLDER/aur_number.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Loop para concatenar os nomes dos pacotes à regex
	for pacote in ${search[*]}; do
		if [[ -n "$regex" ]]; then
			regex+="|"
		fi
		if ((aur_search_category)); then
			regex+="$pacote$"
		else
			regex+="$pacote"
		fi
	done
	if ! ((aur_search_category)) && ((searchInDescription)); then
		regex="($regex)"
	else
		regex="^($regex)"
	fi

	if ! ((aur_search_category)); then
		if ((searchInDescription)); then
			json=$(big-search-aur -Ss ${search} --limit 60 --by-name-desc --json --verbose)
		else
			json=$(big-search-aur -Ss ${search} --limit 60 --by-name --json --verbose)
		fi
	else
		json=$(big-search-aur -Si ${search} --limit 60 --by-name --json --verbose)
	fi

	# Adiciona ^ no início para garantir que a correspondência seja feita no início da linha
	#		if ! ((searchInDescription)); then
	#	#		json=$(LC_ALL=C big-pacman-to-json yay -Ssa --regex "$regex" --sortby popularity --topdown)
	#	#		json=$(LC_ALL=C big-pacman-to-json pacaur -Ssa --regex $regex)
	#			json=$(LC_ALL=C big-pacman-to-json paru -Ssa --regex $regex --limit 60 --sortby popularity --topdown)
	#	#		json=$(LC_ALL=C big-pacman-to-json package-query -Ss --aur $regex)
	#	#		json=$(LC_ALL=C big-pacman-to-json paru --aur -Qs $regex --limit 60 --sortby popularity --topdown)
	#			json=$(big-search-aur -Si ${search} --limit 58 --by-name --json)
	#		else
	#	#		json=$(LC_ALL=C big-pacman-to-json yay -Ssa --regex "$regex" --sortby popularity --searchby name-desc)
	#	#		json=$(LC_ALL=C big-pacman-to-json pacaur -Ssa --regex $regex)
	#			json=$(LC_ALL=C big-pacman-to-json paru -Ssa --regex $regex --limit 60 --sortby popularity --searchby name-desc)
	#	#		json=$(LC_ALL=C big-pacman-to-json package-query -Ss --aur $regex)
	#	#		json=$(LC_ALL=C big-pacman-to-json paru --aur -Qs $regex --limit 60 --sortby popularity --searchby name-desc --topdown)
	#			json=$(big-search-aur -Ss ${search} --limit 58 --by-name --json)
	#		fi

	#search="brave-browser chromium epiphany falkon firefox firefox-i18n-pt-br google-chrome librewolf-bin lynx microsoft-edge-stable-bin opera palemoon-bin vivaldi"
	#json=$(big-search-aur $search --json --by-name | jq -c '{Name, Version, Description}')
	#echo $json

	# Armazene o JSON em uma variável para evitar chamadas jq repetidas
	#	item_json=$(jq -c '{Name, Version, Description}' <<<"$json")
	item_json=$(jq -c '.[] | {Name, Version, Description}' <<<"$json")

	# Use um while loop para processar os itens JSON
	while IFS= read -r item; do
		#		# Usando jq para extrair todos os valores em uma única linha, separados por vírgulas
		#		values=$(jq -r '[.Name, .Version, .Description] | @csv' <<<"$item")
		#		# Remove aspas duplas que o @csv adiciona
		#		values=${values//\"/}
		#		# Lê os valores em variáveis
		#		IFS=',' read -r name version description <<<"$values"

		name=$(jq -r '.Name' <<<"$item")
		version=$(jq -r '.Version' <<<"$item")
		description=$(jq -r '.Description' <<<"$item")
		#		size=$(jq -r '.size' <<<"$item")
		#		status=$(jq -r '.status' <<<"$item")
		pkg=${name#aur/}
		pkg=${name#local/}

		if [[ -n "$name" ]]; then
			# Se NÃO é por categorias
			if ! ((aur_search_category)); then
				# Se NÃO é para buscar na descrição
				if ! ((searchInDescription)); then
					# Se a variável $search NÃO contiver a palavra $pkg
					if [[ ! "$pkg" =~ "$search" ]]; then
						continue
					fi
				fi
			fi

			pkgicon=${pkg//-bin/}
			pkgicon=${pkgicon//-git/}
			pkgicon=${pkgicon//-beta/}
			title=${pkg//-/ }
			unset title_uppercase_first_letter

			for word in $title; do
				title_uppercase_first_letter+=" ${word^}"
			done

			#			if [[ "$status" == *"Installed"* ]]; then
			if [[ -n "$(pacman -Qs "^$name$")" ]]; then
				button="<div id=aur_installed>$Remover_text</div>"
				aur_priority="AurP1"
			else
				button="<div id=aur_not_installed>$Instalar_text</div>"
				if [[ "$search" =~ .*"$title".* ]]; then
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

			summary="$description"
			summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
			pkg_summary_encoded=$(printf '%s' "$summary" | jq -s -R -r @uri)

			{
				echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_summary=$pkg_summary_encoded&pkg_name=$pkg\">"
				echo "<div class=\"col s12 m6 l3\" id=$aur_priority>"
				echo "<div class=\"showapp\">"
				echo "<div id=aur_icon><div class=icon_middle>$icon</div>"
				echo "<div id=aur_name><div id=limit_title_name>$title_uppercase_first_letter</div>"
				echo "<div id=version>$version</div></div></div>"
				echo "<div id=box_aur_desc><div id=aur_desc>$summary</div></div>"
				echo "$button</a></div></div>"
			} >>"$TMP_FOLDER/aur_build.html"
			((++count))
		else
			continue
		fi
	done < <(echo "$item_json")

	if ((count)); then
		echo "$count" >"$TMP_FOLDER/aur_number.html"
		echo "<script>\$(document).ready(function() {\$(\"#box_aur\").show();});</script>" >>"$TMP_FOLDER/aur_build.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	else
		echo "0" >"$TMP_FOLDER/aur_number.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
}
export -f sh_search_aurSearch

#######################################################################################################################

function sh_search_aurRegex() {
	local search="$*"
	local n=1
	local count=0
	local cmd
	local pacote
	local regex=""
	local traducao_online
	local searchFilter_checkbox
	local searchInDescription=0
	local site='https://aur.archlinux.org/packages-meta-v1.json.gz'
	local metapackage="$HOME_FOLDER/packages-meta-v1.json"
	local output_file="$TMP_FOLDER/filtered-results-aur.json"
	local item_json

	[[ -e "$TMP_FOLDER/aur.html" ]] && rm -f "$TMP_FOLDER/aur.html"
	[[ -e "$TMP_FOLDER/aur_build.html" ]] && rm -f "$TMP_FOLDER/aur_build.html"
	[[ -e "$TMP_FOLDER/aur_number.html" ]] && rm -f "$TMP_FOLDER/aur_number.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Loop para concatenar os nomes dos pacotes à regex
	for pacote in ${search[*]}; do
		if [[ -n "$regex" ]]; then
			regex+="|"
		fi
		if ((aur_search_category)); then
			regex+="$pacote$"
		else
			regex+="$pacote"
		fi
	done
	if ! ((aur_search_category)) && ((searchInDescription)); then
		regex="($regex)"
	else
		regex="^($regex)"
	fi

	# Adiciona ^ no início para garantir que a correspondência seja feita no início da linha
	if ! ((searchInDescription)); then
		#	#		json=$(LC_ALL=C big-pacman-to-json yay -Ssa --regex "$regex" --sortby popularity --topdown)
		#	#		json=$(LC_ALL=C big-pacman-to-json pacaur -Ssa --regex $regex)
		#	#		json=$(LC_ALL=C big-pacman-to-json paru -Ssa --regex $regex --limit 60 --sortby popularity --topdown)
		#	#		json=$(LC_ALL=C big-pacman-to-json package-query -Ss --aur $regex)
		#	#		json=$(LC_ALL=C big-pacman-to-json paru --aur -Qs $regex --limit 60 --sortby popularity --topdown)
		json=$(LC_ALL=C big-jq-regex -S "$metapackage" $regex --regex --json --limit 60)
	else
		#	#		json=$(LC_ALL=C big-pacman-to-json yay -Ssa --regex "$regex" --sortby popularity --searchby name-desc)
		#	#		json=$(LC_ALL=C big-pacman-to-json pacaur -Ssa --regex $regex)
		#	#		json=$(LC_ALL=C big-pacman-to-json paru -Ssa --regex $regex --limit 60 --sortby popularity --searchby name-desc)
		#	#		json=$(LC_ALL=C big-pacman-to-json package-query -Ss --aur $regex)
		#	#		json=$(LC_ALL=C big-pacman-to-json paru --aur -Qs $regex --limit 60 --sortby popularity --searchby name-desc --topdown)
		json=$(LC_ALL=C big-jq-regex -S "$metapackage" $regex --regex --json --limit 60)
	fi
	# Armazene o JSON em uma variável para evitar chamadas jq repetidas
	#	item_json=$(jq -c '.[]' <<<"$json")
	#	#	item_json=$(grep -iE "$regex" "$metapackage" | jq -c 'map(select(.Name != null))')
	#	#item_json=$(jq -c --arg regex "$regex" '.[] | select(.Name | test($regex; "i"))' "$metapackage")

	#	item_json=$(jq -c --arg regex "$regex" '
	#    .[] |
	#    select(.Name | test($regex; "i")) |
	#    {Name, Version, Description}
	#' "$metapackage")

	item_json=$(jq -c '{Name, Version, Description}' <<<"$json")

	#	# Divida o arquivo JSON em partes menores
	#	jq -c '.[]' "$metapackage" | split -l 1000 - "$TMP_FOLDER/part_"
	#	# Filtre os arquivos divididos e armazene os resultados na variável
	#	for file in "$TMP_FOLDER"/part_*; do
	#	  item_json+=$(jq -c --arg regex "$regex" '
	#	      select(.Name | test($regex; "i"))
	#	  ' "$file")
	#	  item_json+=$'\n'  # Adiciona uma nova linha para separar os itens JSON
	#	done

	## Divida o arquivo JSON em partes menores para processamento
	#jq -c '.[]' "$metapackage" | split -l 1000 - "$TMP_FOLDER/part_"
	#
	## Função para filtrar e extrair campos necessários
	#filter_and_extract() {
	#    local regex="$1"
	#    local file="$2"
	#
	#    jq -c --arg regex "$regex" '
	#        select(.Name | test($regex; "i")) | {Name, Version, Description}
	#    ' "$file"
	#}
	#
	## Filtre os arquivos divididos e armazene os resultados na variável
	#for file in "$TMP_FOLDER"/part_*; do
	#    item_json+=$(filter_and_extract "$regex" "$file")
	#    item_json+=$'\n'  # Adiciona uma nova linha para separar os itens JSON
	#done

	# Use um while loop para processar os itens JSON
	while IFS= read -r item; do
		#		#Estrutura .json https://aur.archlinux.org/packages-meta-v1.json.gz
		#		{
		#		  "ID": 1389332,
		#		  "Name": "elisa-git",
		#		  "PackageBaseID": 115203,
		#		  "PackageBase": "elisa-git",
		#		  "Version": "24.01.90.r14.g82824891-1",
		#		  "Description": "Simple music player aiming to provide a nice experience for its users",
		#		  "URL": "https://community.kde.org/Elisa",
		#		  "NumVotes": 11,
		#		  "Popularity": 0,
		#		  "OutOfDate": null,
		#		  "Maintainer": "z3ntu",
		#		  "Submitter": "arojas",
		#		  "FirstSubmitted": 1472851887,
		#		  "LastModified": 1705776832,
		#		  "URLPath": "/cgit/aur.git/snapshot/elisa-git.tar.gz"
		#		}

		name=$(jq -r '.Name' <<<"$item")
		version=$(jq -r '.Version' <<<"$item")
		description=$(jq -r '.Description' <<<"$item")
		#		size=$(jq -r '.size' <<<"$item")
		#		status=$(jq -r '.status' <<<"$item")
		pkg=${name#aur/}
		pkg=${name#local/}

		#		# Usando jq para extrair todos os valores em uma única linha, separados por vírgulas
		#		values=$(jq -r '[.Name, .Version, .Description] | @csv' <<<"$item")
		#		# Remove aspas duplas que o @csv adiciona
		#		values=${values//\"/}
		#		# Lê os valores em variáveis
		#		IFS=',' read -r name version description <<<"$values"

		#		if [[ $name == aur/* ]]; then
		#		if [[ $name == local/* ]]; then
		if [[ -n "$name" ]]; then
			# Se NÃO é por categorias
			if ! ((aur_search_category)); then
				# Se NÃO é para buscar na descrição
				if ! ((searchInDescription)); then
					# Se a variável $search NÃO contiver a palavra $pkg
					if [[ ! "$pkg" =~ "$search" ]]; then
						continue
					fi
				fi
			fi

			pkgicon=${pkg//-bin/}
			pkgicon=${pkgicon//-git/}
			pkgicon=${pkgicon//-beta/}
			title=${pkg//-/ }
			unset title_uppercase_first_letter

			for word in $title; do
				title_uppercase_first_letter+=" ${word^}"
			done

			#			if [[ "$status" == *"Installed"* ]]; then
			if [[ -n "$(pacman -Qs "^$name$")" ]]; then
				button="<div id=aur_installed>$Remover_text</div>"
				aur_priority="AurP1"
			else
				button="<div id=aur_not_installed>$Instalar_text</div>"
				if [[ "$search" =~ .*"$title".* ]]; then
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

			summary="$description"
			summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
			pkg_summary_encoded=$(printf '%s' "$summary" | jq -s -R -r @uri)

			{
				echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_summary=$pkg_summary_encoded&pkg_name=$pkg\">"
				echo "<div class=\"col s12 m6 l3\" id=$aur_priority>"
				echo "<div class=\"showapp\">"
				echo "<div id=aur_icon><div class=icon_middle>$icon</div>"
				echo "<div id=aur_name><div id=limit_title_name>$title_uppercase_first_letter</div>"
				echo "<div id=version>$version</div></div></div>"
				echo "<div id=box_aur_desc><div id=aur_desc>$summary</div></div>"
				echo "$button</a></div></div>"
			} >>"$TMP_FOLDER/aur_build.html"
			((++count))
		else
			continue
		fi
	done < <(echo "$item_json")

	if ((count)); then
		echo "$count" >"$TMP_FOLDER/aur_number.html"
		echo "<script>\$(document).ready(function() {\$(\"#box_aur\").show();});</script>" >>"$TMP_FOLDER/aur_build.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	else
		echo "0" >"$TMP_FOLDER/aur_number.html"
		echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >>"$TMP_FOLDER/aur_build.html"
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/aur_build.html" "$TMP_FOLDER/aur.html"
}
export -f sh_search_aurRegex

#######################################################################################################################

function sh_sort_words_alphabetically() {
	local input="$1"
	echo "$input" | tr ' ' '\n' | sort | xargs
}

#######################################################################################################################

function sh_search_appstream() {
	local search="$*"
	local n=1
	local count=0
	local cmd
	local regex=""
	local pacote
	local traducao_online
	local LIMITE=60
	local searchFilter_checkbox
	local searchInDescription=0

	[[ -e "$TMP_FOLDER/category_aur.txt" ]] && rm -f "$TMP_FOLDER/category_aur.txt"
	[[ -e "$TMP_FOLDER/appstream.html" ]] && rm -f "$TMP_FOLDER/appstream.html"
	[[ -e "$TMP_FOLDER/appstream_build.html" ]] && rm -f "$TMP_FOLDER/appstream_build.html"
	[[ -e "$TMP_FOLDER/appstream_number.html" ]] && rm -f "$TMP_FOLDER/appstream_number.html"

	traducao_online=$(TIni.Get "$INI_FILE_BIG_STORE" "bigstore" "traducao_online")
	searchFilter_checkbox="$(TIni.Get "$INI_FILE_BIG_STORE" 'bigstore' 'searchFilter')"
	[[ -n $searchFilter_checkbox ]] && searchInDescription=1

	# Loop para concatenar os nomes dos pacotes à regex
	for pacote in ${search[*]}; do
		if [[ -n "$regex" ]]; then
			regex+="|"
		fi
		if ((appstream_search_category)); then
			#			regex+="($pacote$)"
			regex+="$pacote$"
		else
			#			regex+="($pacote)"
			regex+="$pacote"
		fi
	done

	# Adiciona ^ no início para garantir que a correspondência seja feita no início da linha
	regex="^($regex)"
	json=$(LC_ALL=C big-pacman-to-json pacman -Ss $regex)

	# Armazene o JSON em uma variável para evitar chamadas jq repetidas
	item_json=$(jq -c '.[]' <<<"$json")

	# verifica se o pacote está em nativos, senão passa para o AUR
	#	for pacote in ${search[@]}; do
	#		if [[ $json =~ "\"$pacote\"" ]]; then
	#			continue
	#		fi
	#		echo $pacote >>"$TMP_FOLDER/category_aur.txt"
	#	done

	# Use um while loop para processar os itens JSON
	while IFS= read -r item; do
		#		name=$(jq -r '.name' <<<"$item")
		#		pkg=${name##*/}
		#		description=$(jq -r '.description' <<<"$item")
		#		if [[ -n "$pkg" ]]; then
		#			# Se NÃO é por categorias
		#			if ! ((appstream_search_category)); then
		#				# Se NÃO é para buscar na descrição
		#				if ! ((searchInDescription)); then
		#					# Se a variável $search NÃO contiver a palavra $pkg
		#					if [[ ! "$search" =~ "$pkg" ]]; then
		#						continue
		#					fi
		#				fi
		#			fi
		#			version=$(jq -r '.version' <<<"$item")
		#			size=$(jq -r '.size' <<<"$item")
		#			status=$(jq -r '.status' <<<"$item")

		#		# Função para remover chaves {} e aspas "
		#		sanitize_item() {
		#		  local item="$1"
		#		  # Remove as chaves {} e aspas " ao redor do JSON
		#		  item=${item#\{}
		#		  item=${item%\}}
		#		  echo "$item"
		#		}
		#
		#		# Função para extrair o valor de uma chave usando expansão de parâmetros
		#		get_value() {
		#		  local key="$1"
		#		  local item="$2"
		#
		#		  # Define o padrão para a chave
		#		  local pattern="\"$key\":"
		#
		#		  # Procura o início do valor da chave
		#		  local start=$(echo "$item" | grep -o -P "(?<=${pattern}\")[^\"]*" | head -n 1)
		#
		#		  # Verifica se o valor foi encontrado
		#		  if [[ -z "$start" ]]; then
		#		    echo ""
		#		  else
		#		    echo "$start"
		#		  fi
		#		}
		#
		#		# Limpa o item
		#		item=$(sanitize_item "$item")
		#
		#		# Extrai o valor de cada chave conhecida
		#		name=$(get_value name "$item")
		#		description=$(get_value description "$item")
		#

		# Usando jq para extrair todos os valores em uma única linha, separados por vírgulas
		values=$(jq -r '[.name, .version, .size, .status, .Repo, .description] | @csv' <<<"$item")

		# Remove aspas duplas que o @csv adiciona
		values=${values//\"/}

		# Lê os valores em variáveis
		IFS=',' read -r name version size status Repo description <<<"$values"

		pkg=${name##*/}
		if [[ -n "$pkg" ]]; then
			# Se NÃO é por categorias
			if ! ((appstream_search_category)); then
				# Se NÃO é para buscar na descrição
				if ! ((searchInDescription)); then
					# Se a variável $search NÃO contiver a palavra $pkg
					if [[ ! "$search" =~ "$pkg" ]]; then
						continue
					fi
				fi
			fi
			#			version=$(get_value version "$item")
			#			size=$(get_value size "$item")
			#			status=$(get_value status "$item")
			#			Repo=$(get_value Repo "$item")

			pkgicon=${pkg//-bin/}
			pkgicon=${pkgicon//-git/}
			pkgicon=${pkgicon//-beta/}
			title=${pkg//-/ }
			unset title_uppercase_first_letter

			for word in $title; do
				title_uppercase_first_letter+=" ${word^}"
			done

			if [[ "$status" =~ [I|i]nstalled ]]; then
				id_priority="AppstreamP1"
				file_path="$TMP_FOLDER/upgradeable.txt"
				if grep -q "$pkg" "$file_path"; then
					button="<div id=appstream_upgradable>$Atualizar_text</div>"
				else
					button="<div id=appstream_installed>$Remover_text</div>"
				fi
			else
				button="<div id=appstream_not_installed>$Instalar_text</div>"
				if [[ "$search" =~ .*"$title".* ]]; then
					id_priority="AppstreamP2"
				else
					id_priority="AppstreamP1"
				fi
			fi

			sh_find_icon() {
				local pkgicon="$1"
				find_icon=$(find \
					icons/ /var/lib/flatpak/appstream/ -type f -iname "*$pkgicon*" \
					-print -quit)
				echo $find_icon
			}

			if [[ -e "icons/$pkgicon.png" ]]; then
				icon="<img class=icon src=icons/$pkgicon.png>"
			elif find_icon=$(sh_find_icon "${pkgicon//-*/}") && [[ -e "$find_icon" ]]; then
				icon="<img class=icon src=$find_icon>"
			else
				icon="<div class=avatar_appstream>${pkgicon:0:3}</div>"
			fi

			summary="$description"
			summary=$(sh_translate_desc "$pkg" "$traducao_online" "$description")
			summary="${summary//[\(\)\'\"]/}"

			cat >>"$TMP_FOLDER/appstream_build.html" <<-EOF
				<a onclick="disableBody();" href='view_appstream.sh.htm?pkg_summary=$summary&pkg_name=$pkg'>
				<div class="col s12 m6 l3" id=$id_priority>
				<div class="showapp">
				<div id=appstream_icon>
				<div class=icon_middle>$icon</div>
				<div id=appstream_name>
				<div id=limit_title_name>$title_uppercase_first_letter</div>
				<div id=version>$version</div>
				</div>
				</div>
				<div id=box_appstream_desc>
				<div id=appstream_desc>$summary</div>
				</div>
				$button
				</a>
				</div>
				</div>
			EOF
			((++count))
			if ((count >= LIMITE)); then
				break
			fi
		else
			continue
		fi
	done < <(echo "$item_json")

	if ((count)); then
		echo "$count" >"$TMP_FOLDER/appstream_number.html"
		echo "<script>\$(document).ready(function() {\$(\"#box_appstream\").show();});</script>" >>"$TMP_FOLDER/appstream_build.html"
		echo '<script>document.getElementById("appstream_icon_loading").innerHTML = ""; runAvatarAppstream();</script>' >>"$TMP_FOLDER/appstream_build.html"
	else
		echo "0" >"$TMP_FOLDER/appstream_number.html"
		echo '<script>document.getElementById("appstream_icon_loading").innerHTML = ""; runAvatarAppstream();</script>' >>"$TMP_FOLDER/appstream_build.html"
	fi
	# Move temporary HTML file to final location
	mv "$TMP_FOLDER/appstream_build.html" "$TMP_FOLDER/appstream.html"
}
export -f sh_search_appstream

#######################################################################################################################

function sh_reinstall_allpkg {
	pacman -Sy --noconfirm - < <(pacman -Qnq)
}
export -f sh_reinstall_allpkg

#######################################################################################################################

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

#######################################################################################################################

function sh_pkg_pacman_install_reason {
	grep "^Install Reason " "$TMP_FOLDER/pacman_pkg_cache.txt" | cut -f2 -d:
}
export -f sh_pkg_pacman_install_reason

#######################################################################################################################

function search_appstream_pamac {
	[[ -e "$TMP_FOLDER/appstream_build.html" ]] && rm -f "$TMP_FOLDER/appstream_build.html"
	echo "" >"$TMP_FOLDER/upgradeable.txt"
	pacman -Qu | cut -f1 -d" " >>"$TMP_FOLDER/upgradeable.txt"
	./search_appstream_pamac "${@}" >>"$TMP_FOLDER/appstream_build.html"
	mv "$TMP_FOLDER/appstream_build.html" "$TMP_FOLDER/appstream.html"
}

#######################################################################################################################

#qua 23 ago 2023 22:44:29 -04
function sh_pkg_pacman_version {
	grep "^Version " "${TMP_FOLDER}/pacman_pkg_cache.txt" | cut -f2-10 -d: | awk 'NF'
}
export -f sh_pkg_pacman_version

#######################################################################################################################

function sh_count_snap_list {
	local snap_count=$(snap list | wc -l)
	((snap_count -= 1))
	echo "$snap_count"
}
export -f sh_count_snap_list

#######################################################################################################################

function sh_count_snap_cache_lines {
	wc -l <"$HOME_FOLDER/snap.cache"
}
export -f sh_count_snap_cache_lines

#######################################################################################################################

function sh_SO_installation_date {
	#	ls -lct /etc | tail -1 | awk '{print $6, $7, $8}')
	expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | head -n 1
}
export -f sh_SO_installation_date

#######################################################################################################################

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

#######################################################################################################################

function sh_update_cache_snap {
	local processamento_em_paralelo="$1"
	local verbose="$2"
	local folder_to_save_files="$HOME_FOLDER/snap_list_files/snap_list"
	local file_to_save_cache="$HOME_FOLDER/snap.cache"
	local file_to_save_cache_filtered="$HOME_FOLDER/snap_filtered.cache"
	local path_snap_list_files="$HOME_FOLDER/snap_list_files/"
	local SITE="https://api.snapcraft.io/api/v1/snaps/search?confinement=strict&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media&scope=wide:"
	local URL="https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media,&scope=wide:&page="

	if [[ -z "$processamento_em_paralelo" ]] || [[ "$processamento_em_paralelo" = '0' ]]; then
		processamento_em_paralelo=0
	else
		processamento_em_paralelo=1
	fi

	if [[ -z "$verbose" ]] || [[ "$verbose" = '1' ]]; then
		verbose=1
	else
		verbose=0
	fi

	((verbose)) && echo "${cyan}$(gettext "snap - Criando e removendo necessários arquivos e 'paths'...")${reset}"
	[[ -e "$file_to_save_cache" ]] && rm -f "$file_to_save_cache"
	[[ -e "$file_to_save_cache_filtered" ]] && rm -f "$file_to_save_cache_filtered"
	[[ -d "$path_snap_list_files" ]] && rm -R "$path_snap_list_files"
	mkdir -p "$path_snap_list_files"

	# Anotação com as opções possíveis para utilizar na API
	#https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=anon_download_url,architecture,channel,download_sha3_384,summary,description,binary_filesize,download_url,last_updated,package_name,prices,publisher,ratings_average,revision,snap_id,license,base,media,support_url,contact,title,content,version,origin,developer_id,develope>
	# Anotação com a busca por wps-2019-snap em cache
	# jq -r '._embedded."clickindex:package"[]| select( .package_name == "wps-2019-snap" )' $folder_to_save_files*

	((verbose)) && echo "${cyan}snap - Baixando header: ${red}$SITE${reset}"
	# Lê na pagina inicial quantas paginas devem ser baixadas e salva o valor na variavel $number_of_pages
	number_of_pages="$(curl --silent --compressed --insecure --url "$SITE" | jq -r '._links.last' | sed 's|.*page=||g;s|"||g' | grep '[0-9]')"
	((verbose)) && echo "${cyan}snap - Numero de páginas a serem processadas: ${red}$number_of_pages${reset}"
	((verbose)) && echo "${cyan}snap - Iniciando downloads...${reset}"

	if ((processamento_em_paralelo)); then
		if ((number_of_pages)); then
			# Baixa os arquivos em paralelo
			parallel --gnu --jobs 50% \
				"curl --compressed --silent --insecure -s --url '${URL}{}' --continue-at - --output '${folder_to_save_files}{}'" ::: $(seq 1 $number_of_pages)
			# Filtra e processa os arquivos em paralelo
			parallel --gnu --jobs 50% \
				"jq -r '._embedded.\"clickindex:package\"[]| .title + \"|\" + .snap_id + \"|\" + .media[0].url + \"|\" + .summary + \"|\" + .version + \"|\" + .package_name + \"|\"' '${folder_to_save_files}{}' \
				| sort -u >> '${file_to_save_cache}'" ::: $(seq 1 $number_of_pages)
			# Aguarda o processamento
			wait
			grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/snap_list.txt "$file_to_save_cache" >"$file_to_save_cache_filtered"
		fi
	else #processamento_em_paralelo
		if ((number_of_pages)); then
			for ((page = 1; page <= number_of_pages; page++)); do
				((verbose)) && echo "${cyan}snap - Baixando arquivo em: ${red}${folder_to_save_files}${page}${reset}"
				curl -# --compressed --insecure --url "$URL$page" --continue-at - --output "${folder_to_save_files}${page}" &
			done
			((verbose)) && echo "${cyan}snap - Aguardando o download de todos os arquivos...${reset}"
			wait
			((verbose)) && echo "${cyan}snap - Downloads efetuados, prosseguindo!${reset}"

			((verbose)) && echo "${cyan}Filtrando o resultado dos arquivos e criando um arquivo de cache que será utilizado nas buscas${reset}"
			jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' "$folder_to_save_files*" | sort -u >"$file_to_save_cache"

			for ((page = 1; page <= number_of_pages; page++)); do
				((verbose)) && echo "${reset}Processando com jq a página : ${red}$page/$number_of_pages${reset}"
				#				jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' "${folder_to_save_files}${page}" | sort -u >> "$file_to_save_cache" &
				jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' "${folder_to_save_files}${page}" | sort -u >>"$file_to_save_cache" &
			done
			((verbose)) && echo "${cyan}snap - Processando jq${reset}"
			wait
			((verbose)) && echo "${cyan}snap - Filtrando o resultado com grep${reset}"
			grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/snap_list.txt "$file_to_save_cache" >"$file_to_save_cache_filtered"
		fi
	fi #processamento_em_paralelo

	((verbose)) && echo "${cyan}snap - Registrando informações em: ${red}$INI_FILE_BIG_STORE${reset}"
	TIni.Set "$INI_FILE_BIG_STORE" "snap" "snap_atualizado" '1'
	TIni.Set "$INI_FILE_BIG_STORE" "snap" "snap_data_atualizacao" "$(date "+%d/%m/%y %H:%M")"
	((verbose)) && echo "${green}snap - Feito!${reset}"
}
export -f sh_update_cache_snap

#######################################################################################################################

# qua 11 out 2023 14:19:05 -04
function sh_update_cache_flatpak() {
	local processamento_em_paralelo="$1"
	local verbose="$2"
	local LIST_FILE="/usr/share/bigbashview/bcc/apps/big-store/list/flatpak_list.txt"

	if [[ -z "$processamento_em_paralelo" ]] || [[ "$processamento_em_paralelo" = '0' ]]; then
		processamento_em_paralelo=0
	else
		processamento_em_paralelo=1
	fi

	if [[ -z "$verbose" ]] || [[ "$verbose" = '1' ]]; then
		verbose=1
	else
		verbose=0
	fi

	sleep 0.2

	((verbose)) && echo "${cyan}$(gettext "flatpak - Criando e removendo necessários arquivos e 'paths'...")${reset}"
	[[ -e "$flatpak_cache_file" ]] && rm -f "$flatpak_cache_file"
	[[ -e "$flatpak_cache_filtered_file" ]] && rm -f "$flatpak_cache_filtered_file"

	((verbose)) && echo "${cyan}$(gettext "flatpak - Realizando busca usando ${red}'flatpak search'${reset} e filtrando informações necessárias...")${reset}"
	LC_ALL=C flatpak search --arch=x86_64 "" | awk -F'\t' '
  BEGIN {
      print "["
      first = 1
      OFS = "\t"
  }
  NR > 0 {
		branch = $5
		if (branch == "stable") {
			if (!first) {
				print ","
			}
      first = 0
      name = $1
      desc = $2
      id = $3
      version = $4
      remote = $6

			# Remove aspas internas na descrição
    	gsub(/"/, "", desc)

			# Remove espaços extras no início e no fim da descrição
    	sub(/^ +/, "", desc)
    	sub(/ +$/, "", desc)

			# Imprimir o objeto JSON no arquivo de saída
    	print "  {"
    	print "    \"name\": \"" name "\","
	    print "    \"version\": \"" version "\","
  	  print "    \"size\": \"\","
			print "    \"icon\": \"\","
			print "    \"id_name\": \"" id "\","
			print "    \"branch\": \"" branch "\","
			print "    \"remotes\": \"" remote "\","
			print "    \"description\": \"" desc "\""
			print "  }"
		}
  }
  END {
      print "]"
	}' >"$TMP_FOLDER/input.json"

	((verbose)) && echo "${cyan}$(gettext "flatpak - Realizando Ordenação do arquivo JSON ${red}${flatpak_cache_file}${reset}...")${reset}"
	jq 'sort_by(.name) | unique_by(.name)' "$TMP_FOLDER/input.json" >"$flatpak_cache_file"

	#	for i in $(LC_ALL=C flatpak update | grep "^ [1-9]" | awk '{print $2}'); do
	#		sed -i "s/|${i}.*/&update|/" "$flatpak_cache_file"
	#	done

	((verbose)) && echo "${cyan}$(gettext "flatpak - Realizando filtragem de pacotes Flatpak...")${reset}"
	grep -Fwf "$LIST_FILE" "$flatpak_cache_file" >"$flatpak_cache_filtered_file"

	((verbose)) && echo "${cyan}flatpak - Registrando informações em: ${red}$INI_FILE_BIG_STORE${reset}"
	TIni.Set "$INI_FILE_BIG_STORE" "flatpak" "flatpak_atualizado" '1'
	TIni.Set "$INI_FILE_BIG_STORE" "flatpak" "flatpak_data_atualizacao" "$(date "+%d/%m/%y %H:%M")"
	if ((verbose)); then
		echo "${green}$(gettext "flatpak - Feito!")${reset}"
	fi
	sleep 2
}
export -f sh_update_cache_flatpak

#######################################################################################################################

function sh_update_cache_complete {
	[[ ! -d "$HOME_FOLDER" ]] && mkdir -p "$HOME_FOLDER"
	[[ -e "/usr/lib/libpamac-flatpak.so" ]] && sh_update_cache_flatpak "$@"
	[[ -e "/usr/lib/libpamac-snap.so" ]] && sh_update_cache_snap "$@"
}
export -f sh_update_cache_complete

#######################################################################################################################

function sh_run_pacman_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pacman_mirror

#######################################################################################################################

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

#######################################################################################################################

function sh_package_is_installed {
	pacman -Q $1 >/dev/null 2>&-
	return $?
}
export -f sh_package_is_installed

#######################################################################################################################

function sh_enable_snapd_and_apparmor() {
	local result

	sleep 0.1
	echo "$(gettext "Verificando o status do serviço apparmor...")"
	result=$(systemctl is-active apparmor)
	if [[ "$result" = 'failed' || "$result" = 'inactive' ]]; then
		echo "$(gettext "O serviço apparmor está no status 'failed' ou 'inactive'")"
		pacman -Q apparmor
		echo "$(gettext "Ativando e iniciando o serviço apparmor...")"
		sudo systemctl enable --now apparmor
	fi

	echo "$(gettext "Verificando o status do serviço snapd.socket...")"
	result=$(systemctl is-active snapd.socket)
	if [[ "$result" = 'failed' || "$result" = 'inactive' ]]; then
		echo "$(gettext "O serviço snapd.socket está no status 'failed' ou 'inactive'")"
		pacman -Q snapd
		echo "$(gettext "Ativando e iniciando o serviço snapd.socket...")"
		sudo systemctl enable --now snapd.socket
	fi

	echo "$(gettext "Verificando o status do serviço snapd...")"
	result=$(systemctl is-active snapd)
	if [[ "$result" = 'failed' || "$result" = 'inactive' ]]; then
		echo "$(gettext "O serviço snapd está no status 'failed' ou 'inactive'")"
		pacman -Q snapd
		echo "$(gettext "Ativando e iniciando o serviço snapd...")"
		sudo systemctl enable --now snapd
	fi

	echo "$(gettext "Verificando o status do serviço snapd.apparmor...")"
	result=$(systemctl is-active snapd.apparmor)
	if [[ "$result" = 'failed' || "$result" = 'inactive' ]]; then
		echo "$(gettext "Ativando e iniciando o serviço snapd.apparmor...")"
		sudo systemctl enable --now snapd.apparmor
	fi

	echo
	echo -n "systemctl is-active apparmor      : "
	systemctl is-active apparmor
	echo -n "systemctl is-active snap.socket   : "
	systemctl is-active snapd.socket
	echo -n "systemctl is-active snap          : "
	systemctl is-active snapd
	echo -n "systemctl is-active snapd.apparmor: "
	systemctl is-active snapd.apparmor
	sleep 5
}
export -f sh_enable_snapd_and_apparmor

#######################################################################################################################

function sh_toggle_comment_pamac_conf() {
	local action="$1"
	local keyword="$2"
	local file="$3"

	#xdebug "${1+$@}"
	case "$action" in
	1 | comment) action='comment' ;;
	0 | uncomment) action='uncomment' ;;
	*) action='uncomment' ;;
	esac

	if [ "$action" == "comment" ]; then
		sudo sed -i "s/^\($keyword\)/#\1/" "$file"
		return $?
	elif [ "$action" == "uncomment" ]; then
		sudo sed -i "s/^#\($keyword\)/\1/" "$file"
		return $?
	else
		return 2
	fi
}
export -f sh_toggle_comment_pamac_conf

#######################################################################################################################

function sh_check_status_simple_install() {
	# Caminho para o arquivo de configuração
	local config_file="/etc/pamac.conf"

	# Verifica se a linha está comentada
	if grep -q "^#SimpleInstall" "$config_file"; then
		#SimpleInstall está comentado
		echo 1
		return 1
	elif grep -q "^SimpleInstall" "$config_file"; then
		#SimpleInstall não está comentado.
		echo 0
		return 0
	else
		#SimpleInstall não está presente no arquivo.
		echo 2
		return 2
	fi
}
export -f sh_check_status_simple_install

#######################################################################################################################

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

#######################################################################################################################

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

#######################################################################################################################

function sh_run_pamac_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pamac_mirror

#######################################################################################################################

# qua 23 ago 2023 19:20:09 -04
function sh_pkg_flatpak_version {
	[[ -e "$HOME_FOLDER/flatpak-verification-fault" ]] && rm -f "$HOME_FOLDER/flatpak-verification-fault"
	if ! grep -i "$1|" "$flatpak_cache_file" | cut -f4 -d"|"; then
		echo "$1" >"$HOME_FOLDER/flatpak-verification-fault"
	fi
}
export -f sh_pkg_flatpak_version

#######################################################################################################################

# qua 23 ago 2023 19:20:09 -04
function sh_pkg_flatpak_verify {
	echo "$1" >"$HOME_FOLDER/flatpak-verification-fault"
}
export -f sh_pkg_flatpak_verify

#######################################################################################################################

# qua 23 ago 2023 19:20:09 -04
function sh_pkg_flatpak_update {
	grep -i "$1|" "$flatpak_cache_file" | cut -f6 -d"|"
}
export -f sh_pkg_flatpak_update

#######################################################################################################################

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

#######################################################################################################################

# qua 23 ago 2023 20:37:16 -04
function sh_this_package_update {
	pacman -Qu "$1" 2>/dev/null | awk '{print $NF}'
}
export -f sh_this_package_update

#######################################################################################################################

# determina se o fundo do KDE está em modo claro ou escuro
function sh_bstr_getbgcolor() {
	local result
	local r g b
	local average_rgb

	if lightmode="$(TIni.Get "$INI_FILE_BIG_STORE" 'config' 'lightmode')" && [[ -z "$lightmode" ]]; then
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
		TIni.Set "$INI_FILE_BIG_STORE" 'config' 'lightmode' "$lightmode"
	fi

	if ((lightmode)); then
		echo '<body class=light-mode>'
	else
		echo '<body>'
	fi
}
export -f sh_bstr_getbgcolor

#######################################################################################################################

function sh_bstr_setbgcolor() {
	local param="$1"
	local lightmode=1

	[[ "$param" = "true" ]] && lightmode=0
	TIni.Set "$INI_FILE_BIG_STORE" 'config' 'lightmode' "$lightmode"
}
export -f sh_bstr_setbgcolor

#######################################################################################################################

function sh_bcfg_setbgcolor() {
	local param="$1"
	local lightmode=1

	[[ "$param" = "true" ]] && lightmode=0
	TIni.Set "$INI_FILE_BIG_CONFIG" 'config' 'lightmode' "$lightmode"
}
export -f sh_bcfg_setbgcolor

#######################################################################################################################

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
