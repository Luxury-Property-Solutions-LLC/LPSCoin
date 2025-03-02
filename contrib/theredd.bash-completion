# bash programmable completion for lpscoinsd(1)
# Copyright (c) 2012-2025 The LPSCoin Developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

have lpscoinsd && {

# Call $lpscoinsd for RPC
_lpscoin_rpc() {
    # Determine already specified args necessary for RPC
    local rpcargs=()
    for i in "${COMP_WORDS[@]}"; do
        case "$i" in
            -conf=*|-proxy=*|-rpc*)
                rpcargs+=( "$i" )
                ;;
        esac
    done
    "$lpscoinsd" "${rpcargs[@]}" "$@"
}

# Add LPSCoin accounts to COMPREPLY
_lpscoin_accounts() {
    local accounts
    accounts=$(_lpscoin_rpc listaccounts 2>/dev/null | awk '/".*"/ { a=$1; gsub(/"/, "", a); print a}')
    COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W "$accounts" -- "$cur" ) )
}

_lpscoinsd() {
    local cur prev words=() cword
    local lpscoinsd="$1"

    COMPREPLY=()
    _get_comp_words_by_ref -n = cur prev words cword

    if ((cword > 4)); then
        case "${words[cword-4]}" in
            listtransactions)
                COMPREPLY=( $( compgen -W "true false" -- "$cur" ) )
                return 0
                ;;
            signrawtransaction)
                COMPREPLY=( $( compgen -W "ALL NONE SINGLE ALL|ANYONECANPAY NONE|ANYONECANPAY SINGLE|ANYONECANPAY" -- "$cur" ) )
                return 0
                ;;
        esac
    fi

    if ((cword > 3)); then
        case "${words[cword-3]}" in
            addmultisigaddress)
                _lpscoin_accounts
                return 0
                ;;
            getbalance|gettxout|importaddress|importprivkey|listreceivedbyaccount|listreceivedbyaddress|listsinceblock)
                COMPREPLY=( $( compgen -W "true false" -- "$cur" ) )
                return 0
                ;;
        esac
    fi

    if ((cword > 2)); then
        case "${words[cword-2]}" in
            addnode)
                COMPREPLY=( $( compgen -W "add remove onetry" -- "$cur" ) )
                return 0
                ;;
            getblock|getrawtransaction|gettransaction|listaccounts|listreceivedbyaccount|listreceivedbyaddress|sendrawtransaction)
                COMPREPLY=( $( compgen -W "true false" -- "$cur" ) )
                return 0
                ;;
            move|setaccount)
                _lpscoin_accounts
                return 0
                ;;
        esac
    fi

    case "$prev" in
        backupwallet|dumpwallet|importwallet)
            _filedir
            return 0
            ;;
        getmempool|lockunspent|setgenerate)
            COMPREPLY=( $( compgen -W "true false" -- "$cur" ) )
            return 0
            ;;
        getaccountaddress|getaddressesbyaccount|getbalance|getnewaddress|getreceivedbyaccount|listtransactions|move|sendfrom|sendmany)
            _lpscoin_accounts
            return 0
            ;;
    esac

    case "$cur" in
        -conf=*|-pid=*|-loadblock=*|-wallet=*|-rpcsslcertificatechainfile=*|-rpcsslprivatekeyfile=*)
            cur="${cur#*=}"
            _filedir
            return 0
            ;;
        -datadir=*)
            cur="${cur#*=}"
            _filedir -d
            return 0
            ;;
        -*=*) # Prevent nonsense completions
            return 0
            ;;
        *)
            local helpopts commands

            # Parse --help if sensible
            if [[ -z "$cur" || "$cur" =~ ^- ]]; then
                helpopts=$("$lpscoinsd" --help 2>&1 | awk '$1 ~ /^-/ { sub(/=.*/, "="); print $1 }')
            fi

            # Parse help if sensible
            if [[ -z "$cur" || "$cur" =~ ^[a-z] ]]; then
                commands=$(_lpscoin_rpc help 2>/dev/null | awk '$1 ~ /^[a-z]/ { print $1; }')
            fi

            COMPREPLY=( $( compgen -W "$helpopts $commands" -- "$cur" ) )

            # Prevent space if an argument is desired
            if [[ "${COMPREPLY[*]}" == *= ]]; then
                compopt -o nospace
            fi
            return 0
            ;;
    esac
}

complete -F _lpscoinsd lpscoinsd
}

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh
