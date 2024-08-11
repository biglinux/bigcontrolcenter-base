#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC2094,SC2128
#shellcheck source=/dev/null

#  tinilib.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2023/09/27
#  Altered: 2024/06/30
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

[[ -n "$LIB_TINILIB_SH" ]] && return
LIB_TINILIB_SH=1


APP="${0##*/}"
_DATE_ALTERED_="30-06-2024 - 06:00"
_VERSION_="1.0.0-20240630"
_INILIB_VERSION_="${_VERSION_} - ${_DATE_ALTERED_}"
_UPDATED_="${_DATE_ALTERED_}"
#BOOTLOG="/tmp/bigcontrolcenter-$USER-$(date +"%d%m%Y").log"
LOGGER='/dev/tty8'

# Função para atualizar um valor no arquivo INI ou criar o arquivo se não existir
# Exemplo de uso: atualize o valor da chave "versao" da seção "App" no arquivo "config.ini"
# TIni.Set "config.ini" "App" "versao" "2.0"
function TIni.Set {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local new_value="$4"
	local ident_keys=1

	declare -A ini_data # Array associativo para armazenar as seções e chaves

	if [[ -r "$config_file" ]]; then
		# Ler o arquivo INI e armazenar as informações em um array associativo
		local current_section=""
		while IFS= read -r line; do
			if [[ "$line" =~ ^\[(.*)\] ]]; then
				current_section="${BASH_REMATCH[1]}"
			elif [[ "$line" =~ ^([^=]+)=(.*) ]]; then
				local current_key="${BASH_REMATCH[1]}"
				local current_value="${BASH_REMATCH[2]}"
				ini_data["$current_section,$current_key"]="$current_value"
			fi
		done <"$config_file"
	fi

	# Atualizar o valor no array associativo
	ini_data["$section,$key"]="$new_value"

	# Reescrever o arquivo INI com as seções e chaves atualizadas
	echo "" >"$config_file"
	local current_section=""
	for section_key in "${!ini_data[@]}"; do
		local section_name="${section_key%,*}"
		local key_name="${section_key#*,}"
		local value="${ini_data[$section_key]}"

		# Verifique se a seção já foi gravada
		if [[ "$current_section" != "$section_name" ]]; then
			echo "" >>"$config_file"
			echo "[$section_name]" >>"$config_file"
			current_section="$section_name"
		fi
		echo "$key_name=$value" >>"$config_file"
	done
	#	TIni.AlignAllSections "$config_file"
	#	big-tini-pretty -q "$config_file"
	TIni.Sanitize "$config_file"
}
export -f TIni.Set

function TIni.Sanitize() {
	local ini_file="$1"
	local tempfile1
	local tempfile2

	# Criar arquivos temporários
	tempfile1=$(mktemp)
	tempfile2=$(mktemp)

	# Remover linhas em branco do arquivo original
	sed '/^$/d' "$ini_file" >"$tempfile1"

	# Consolidar seções usando awk e salvar no segundo arquivo temporário
	awk '
	BEGIN {
	    section = ""
	}
	{
	    if ($0 ~ /^\[.*\]$/) {
	        section = $0
	    } else if (section != "") {
	        sections[section] = sections[section] "\n" $0
	    }
	}
	END {
    for (section in sections) {
        print section sections[section] "\n"
    }
	}
	' "$tempfile1" >"$tempfile2"

	sed '/^\s*$/d' "$tempfile2" >"$ini_file"

	# colocar uma linha em branco entre as sessoes e remover a primeira linha em branco
	sed -i -e '/^\[/s/\[/\n&/' -e '1{/^[[:space:]]*$/d}' "$ini_file"
	sed -i -e '1{/^[[:space:]]*$/d}' "$ini_file"

	# marcar como executável
	chmod +x "$ini_file"

	# Remover arquivos temporários
	rm "$tempfile1" "$tempfile2"
}
export -f TIni.Sanitize

function TIni.Clean() {
	local ini_file="$1"

	sed -i -e '/./,$!d' -e 's/[ \t]*=[ \t]*/=/' "$ini_file"
	#	awk -F'=' '{
	#		gsub(/^[ \t]+|[ \t]+$/, "", $1);
	#		gsub(/^[ \t]+|[ \t]+$/, "", $2);
	#		print $1 "=" $2
	#	}' "$ini_file" | tee "$ini_file"

}
export -f TIni.Clean

# Função para atualizar o valor de uma chave em uma seção no arquivo INI
function TIni.UpdateValue {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local new_value="$4"

	if [[ -f "$config_file" ]]; then
		sed -i "/^\[$section\]/s/^$key=.*/$key=$new_value/" "$config_file"
	fi
}
export -f TIni.UpdateValue

# Função para verificar se um valor em uma seção corresponde a um valor de referência em um arquivo INI
# TIni.ExistValue "config.ini" "flatpak" "active" '0'; echo $?
function TIni.ExistValue {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local comp_value="$4"

	if [[ -f "$config_file" ]]; then
		local section_found=false
		local key_found=false
		local value=""

		while IFS= read -r line; do
			if [[ "$line" == "[$section]" ]]; then
				section_found=true
			elif [[ "$line" == "["* ]]; then
				section_found=false
			fi

			if [[ "$section_found" == true && "$line" == "$key="* ]]; then
				value=$(echo "$line" | cut -d'=' -f2)
				key_found=true
			fi

			if [[ "$section_found" == true && "$key_found" == true ]]; then
				if [[ "$value" == "$comp_value" ]]; then
					return 0 # Valor encontrado e corresponde ao valor de referência
				else
					return 1 # Valor encontrado, mas não corresponde ao valor de referência
				fi
			fi
		done <"$config_file"
	fi
	return 2 # Seção ou chave não encontrada no arquivo INI
}
export -f TIni.ExistValue

# Função para ler um valor do arquivo INI
# TIni.ReadValue "config.ini" "flatpak" "active"
function TIni.ReadValue() {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local found_section=false

	# Variável para armazenar o valor encontrado
	local value=""

	# Use grep para encontrar a chave na seção especificada no arquivo INI
	while IFS= read -r line; do
		if [[ "$line" =~ ^\[$section\] ]]; then
			found_section=true
		elif [[ "$found_section" == true && "$line" =~ ^$key= ]]; then
			# Encontramos a chave dentro da seção
			value=$(echo "$line" | cut -d'=' -f2)
			break # Saia do loop, pois encontramos o valor
		elif [[ "$line" =~ ^\[.*\] ]]; then
			# Se encontrarmos outra seção, saia do loop para evitar procurar em outras seções
			found_section=false
		fi
	done <"$config_file"

	# Verifique se encontramos o valor
	if [[ -n "$value" ]]; then
		echo "$value"
	else
		echo "Chave não encontrada."
	fi
}
export -f TIni.ReadValue

function TIni.AlignIniFileOLD() {
	local fini="$1"
	local fini_tmp

	[[ ! -e "$fini" ]] && return 2
	fini_tmp=(mktemp "$fini-xxx")
	awk 'BEGIN { insection=0; } /^\[.*\]$/ { if (!seen[$0]++) print; insection=1; next; } insection { print; }' "$fini" >"$fini_tmp"
	sed -i '/^[[:space:]]*$/d' "$fini_tmp"
	mv -f "$fini_tmp" "$fini"
}
export -f TIni.AlignIniFileOLD

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

function TIni.Get() {
	local config_file="$1"
	local section="$2"
	local key="$3"

	[[ ! -e "$config_file" ]] && echo "" >"$config_file"
	sed -nr "/^\[$section\]/ { :l /^[[:space:]]*${key}[[:space:]]*=/ { s/[^=]*=[[:space:]]*//; p; q;}; /^;/b; n; b l;}" "$config_file"
}
export -f TIni.Get

# Função para remover uma chave de um arquivo de configuração INI
function TIni.Delete() {
	local config_file="$1"
	local section="$2"
	local key="$3"

	# Verifica se o arquivo de configuração existe
	if [ ! -f "$config_file" ]; then
		return 2
	fi

	# Usa sed para remover a chave do arquivo de configuração
	sed -i "/^\[$section\]/,/^$/ { /^\s*$key\s*=/d }" "$config_file"
}
export -f TIni.Delete

function TIni.GetAwk() {
	local config_file="$1"
	local section="$2"
	local key="$3"

	[[ ! -e "$config_file" ]] && return 2
	awk -F "=" -v section="$section" -v key="$key" '{
        gsub(/^[ \t]+|[ \t]+$/, "", $1);  # Remova espaços em branco em torno do nome da chave
        if ($0 ~ "^\\[" section "\\]") {   # Verifique se estamos na seção correta
            in_section = 1
        } else if (in_section && $1 == key) {  # Se estivermos na seção correta, procure a chave
            gsub(/^[ \t]+|[ \t]+$/, "", $2);  # Remova espaços em branco em torno do valor
            print $2
            found = 1
        } else if ($0 ~ "^\\[.*\\]") {  # Se encontrarmos outra seção, saia da seção atual
            in_section = 0
        }
    }
    END {
        if (found != 1) {
            # print "Chave não encontrada"
        }
    }' "$config_file"
}
export -f TIni.GetAwk

function TIni.GetAwk2() {
	local config_file="$1"
	local section="$2"
	local key="$3"

	[[ ! -e "$config_file" ]] && return 2
	awk -v chave="$key" -F '=' '!/^;/ && $0 ~ chave { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2 }' "$config_file"
}
export -f TIni.GetAwk2

function TIni.GetMaxKeySize() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 0
	awk -F '=' '/^[^#]/ {
        key = gensub(/^[[:space:]]+|[[:space:]]+$/, "", "g", $1); # Remove espaços em branco no início e no fim da chave
        current_key_size = length(key);
        if (current_key_size > max_key_size) {
            max_key_size = current_key_size;
        }
    } END {
        print max_key_size
    }' "$config_file"
}
export -f TIni.GetMaxKeySize

function TIni.GetSection() {
	local config_file="$1"
	local section="$2"
	local key="$3"
	sed -nr "/^\[$section\]/ { :l /^\s*[^#].*/ p; n; /^\[/ q; b l; }" "$config_file" | grep -E "^\s*[^#].*\s*=" | column -t
}
export -f TIni.GetSection

function TIni.GetAllSections() {
	local config_file="$1"
	local key="$2"

	# Obtém todas as seções do arquivo
	local sections
	sections=$(sed -n '/^\[.*\]$/s/\[\(.*\)\]/\1/p' "$config_file")

	# Itera sobre cada seção
	for section in $sections; do
		echo "[$section]"
		sed -nr "/^\[$section\]/,/^(\[|\s*$)/p" "$config_file" |
			grep -E "^\s*[^#].*\s*=" |
			sed 's/^\s*//;s/\s*$//' |
			sed 's/=/ = /' |
			column --table --table-columns chave,=,valor,valor1 --table-hide - |
			sed 1d
		echo # Adiciona uma linha em branco entre as seções
	done
}
export -f TIni.GetAllSections

function TIni.ParseToAssoc() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 2
	awk -F ' *= *' '{
	    if ($1 ~ /^\[/) {
    	    section=substr($1, 2, length($1)-2);  # Remove os colchetes da seção
	    } else if ($1 !~ /^$/ && $1 !~ /^;/) {
    	    print section "[" $1 "]=\"" $2 "\""
	    }
	}' "$config_file"
}
export -f TIni.ParseToAssoc

function TIni.ParseToVar() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 2
	awk -F ' *= *' '{
        if ($1 ~ /^\[/) {
            section=substr($1, 2, length($1)-2);  # Remove os colchetes da seção
        } else if ($1 !~ /^$/ && $1 !~ /^;/) {
            print $1 "=" "\"" $2 "\""
        }
    }' "$config_file"
}
export -f TIni.ParseToVar

function TIni.ParseToDeclareAssoc() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 2
	while IFS='=' read -r key value; do
		# Verifique se a chave não começa com ;
		if [[ ! $key =~ ^\;.* ]]; then
			if [[ $key == \[*] ]]; then
				# Remova os colchetes [ ]
				key="${key/\[/}"
				key="${key/\]/}"
				section=$key
			elif [[ $value ]]; then
				declare "${section}[${key}]=\"${value}\""
			fi
		fi
	done <"$config_file"
}
export -f TIni.ParseToDeclareAssoc

function TIni.ParseToDeclareVar() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 2
	while IFS='=' read -r key value; do
		# Verifique se a chave não começa com ;
		if [[ ! $key =~ ^\;.* ]]; then
			if [[ $key == \[*] ]]; then
				# Remova os colchetes [ ]
				key="${key/\[/}"
				key="${key/\]/}"
				section=$key
			elif [[ $value ]]; then
				declare "${key}=\"${value}\""
			fi
		fi
	done <"$config_file"
}
export -f TIni.ParseToDeclareVar

function TIni.ParseToDeclareArray() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 2
	while IFS='=' read -r key value; do
		# Verifique se a chave não começa com ;
		if [[ ! $key =~ ^\;.* ]]; then
			if [[ $key == \[*] ]]; then
				# Remova os colchetes [ ]
				key="${key/\[/}"
				key="${key/\]/}"
				section=$key
			elif [[ $value ]]; then
				declare "${key}=(\"${value}\")"
			fi
		fi
	done <"$config_file"
}
export -f TIni.ParseToDeclareArray

function TIni.ParseToArray() {
	local config_file="$1"

	[[ ! -e "$config_file" ]] && return 2
	awk -F ' *= *' '{
        if ($1 ~ /^\[/) {
            section=substr($1, 2, length($1)-2);  # Remove os colchetes da seção
        } else if ($1 !~ /^$/ && $1 !~ /^;/) {
            print section "-" $1 "=(" "\"" $2 "\"" ")"
        }
    }' "$config_file"
}
export -f TIni.ParseToArray

function TIni.AlignAllSections() {
	local config_file="$1"
	local chave_identada="$2"
	local print="$3"
	local temp_file
	local max_size
	local sections
	local current_section=""

	[[ ! -e "$config_file" ]] && return 2
	temp_file=$(mktemp)
	if [[ -n "$chave_identada" || "$chave_identada" -eq 1 ]]; then
		chave_identada=1
		# Obtém o tamanho da string da maior chave (nome da chave) no arquivo INI
		max_size=$(TIni.GetMaxKeySize "$config_file")
	else
		chave_identada=0
	fi
	# Obtém todas as seções do arquivo
	sections=$(sed -n '/^\[.*\]$/s/\[\(.*\)\]/\1/p' "$config_file")

	# Itera sobre cada linha do arquivo
	while IFS= read -r line; do
		if [[ "$line" =~ ^\[(.*)\]$ ]]; then
			current_section="${BASH_REMATCH[1]}"
			echo "$line"
		elif [[ "$line" =~ ^[^#]*= ]]; then
			if ((chave_identada)); then
				# formatar com identação
				awk -F'=' -v section="$current_section" -v max="$max_size" '{ printf "%-*s= %s\n", max+1, $1, $2}' <<<"$line"
			else
				# formatar sem identação
				echo "$current_section.$line"
			fi
		else
			echo "$line"
		fi
	done <"$config_file" >>"$temp_file"

	cp "$temp_file" "$config_file"
	[[ -n "$print" ]] && echo "$(<"$config_file")"
}
export -f TIni.AlignAllSections

function TIni.AlignIniFile {
	local config_file="$1"
	local chave_identada="$2"
	local print="$3"

	[[ ! -e "$config_file" ]] && return 2
	TIni.AlignAllSections "$config_file" "$chave_identada" "$print"
}
export -f TIni.AlignIniFile

# Se a chave e o valor forem exatamente iguais, a função retorna 0.
# Se a chave for encontrada, mas o valor não for igual, a função retorna 2.
# Se a chave não for encontrada, a função retorna 1.
# Se a chave for encontrada com um ponto e vírgula no início, a função também retorna 2.
function TIni.Exist() {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local value="$4"
	local result=1 # Inicializa como 1, indicando que a chave não foi encontrada

	[[ ! -e "$config_file" ]] && return 2
	result=$(awk -F "=" -v section="$section" -v key="$key" -v value="$value" '
        BEGIN {
            encontrado = 1  # Inicializa como 1, indicando que a chave não foi encontrada
        }
        {
            gsub(/^[ \t]+|[ \t]+$/, "", $1);  # Remova espaços em branco em torno do nome da chave
            if ($0 ~ "^\\[" section "\\]") {   # Verifique se estamos na seção correta
                in_section = 1
            } else if (in_section) {
                if ($1 == key) {  # Se estivermos na seção correta, procure a chave
                    if ($0 ~ /^[[:space:]]*;/) {
                        encontrado = 2  # Chave encontrada com ponto e vírgula no início
                        exit
                    }
                    gsub(/^[ \t]+|[ \t]+$/, "", $2);  # Remova espaços em branco em torno do valor
                    if ($0 !~ /^[[:space:]]*;/) {  # Verifique se não é um comentário
                        if (value == "") {
                            encontrado = 0  # Chave encontrada sem valor especificado
                            exit
                        } else if ($2 == value) {
                            encontrado = 0  # Chave encontrada com o valor correto
                            exit
                        } else {
                            encontrado = 2  # Valor fornecido não é igual ao valor da chave
                            exit
                        }
                    }
                }
            } else if ($0 ~ "^\\[.*\\]") {  # Se encontrarmos outra seção, saia da seção atual
                in_section = 0
            }
        }
        END {
            print encontrado
        }
    ' "$config_file")
	return "$result"
}
export -f TIni.Exist

# Exemplo de uso:
# TIni.Set arquivo.ini snap vilmar 5.7
function TIni.WriteValue() {
	local config_file="$1"
	local section="$2"
	local key="$3"
	local value="$4"
	local found_section=0

	if [ ! -f "$config_file" ]; then
		# Se não existir, crie o arquivo com a seção, chave e valor fornecidos
		{
			echo "[$section]"
			echo "$key=$value"
		} >>"$config_file"
		return
	fi

	while IFS= read -r line; do
		if [[ "$line" =~ ^\[$section\] ]]; then
			found_section=1
		elif [[ "$found_section" -eq 1 && "${line}" =~ ^${key}[[:space:]]*=[[:space:]]* ]]; then
			# Se a seção e a chave existem, atualize o valor
			sed -i "s/^${key}[[:space:]]*=[[:space:]]*.*/${key}=${value}/" "$config_file"
			return
		fi
	done <"$config_file"

	# Se a seção não existir, crie-a e adicione a chave e o valor
	if [[ "$found_section" -eq 0 ]]; then
		{
			echo ""
			echo "[$section]"
		} >>"$config_file"
	fi
	echo "$key=$value" >>"$config_file"
}
export -f TIni.WriteValue

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
