#!/bin/bash

[[ $# -ne 1 ]] && [[ $# -ne 2 ]] && die "Usage: $PROGRAM $COMMAND [--clip,-c] pass-name"

if [[ $1 = "-c" ]] || [[ $1 = "--clip"  ]]; then
    local clip=1
    local path="$2"
elif [[ $2 = "-c" ]] || [[ $2 = "--clip"  ]]; then
    local clip=1
    local path="$1"
else
    local clip=0
    local path="$1"
fi

local passfile="$PREFIX/$path.gpg"
check_sneaky_paths "$path"
set_gpg_recipients "$(dirname "$path")"
set_git $passfile

if [[ -f $passfile ]]; then
    local file_contents=`$GPG -d "${GPG_OPTS[@]}" "$passfile"`

    local all_backup_codes=`echo "$file_contents" | sed -n '/^## pass-bc/,/^## pass-bc/{ /##/d ; p}'`
    if [[ -z "$all_backup_codes" ]]; then
        die "Error: $passfile needs pass-bc '## pass-bc' inclosed backup codes"
    fi

    local backup_code=`echo "$all_backup_codes" | grep -m 1 "^[^#;]"`

    if [[ -z "$backup_code" ]]; then
        die "Unable to get backup code"
    fi

    local updated_file_contents=`sed "s/$backup_code/# $backup_code/" <<< $file_contents`

    if [[ $clip -eq 0 ]]; then
        echo $backup_code
    else
        clip "$backup_code" "Backup code for $path"
    fi
    $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" <<< "$updated_file_contents"

    git_add_file "$passfile" "Used backup code for $path."
elif [[ -z $path ]]; then
    die ""
else
    die "Error: $path is not in the password store."
fi
