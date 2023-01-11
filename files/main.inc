die () {
        local rc=$1
        shift
        [ -z "$@" ] || echo "${BASH_SOURCE[1]}:${BASH_LINENO[0]} => " "$@" >&2
        exit $rc
}

set_setting() {
    local key=$1
    local value=$2
    local exists=$(xmlstarlet sel -t -v "count(/appSettings/add[@key='${key}'])" "${APPSETTINGS}")

    if [ -z "$2" ]; then
        return 0
    fi

    if [ $exists -eq 0 ]; then
        xmlstarlet ed -L -s  "/appSettings" \
            -t elem -n add -v "" -i "/appSettings/add[last()]" \
            -t attr -n key -v "$key" -i "/appSettings/add[last()]" \
            -t attr -n value -v "$value" \
            "${APPSETTINGS}"
    else
        xmlstarlet ed -L -u "/appSettings/add[@key='${key}']/@value" -v "${value}" "${APPSETTINGS}"
    fi
}

set_connstr() {
    local name=$1
    local value=$2

    xmlstarlet ed -L -u "/connectionStrings/add[@name='${name}']/@connectionString" -v "${value}" "${CONNSTRINGS}"
}

load_mono_certs_from()
{
    local certsdir=$1

    [ -d "$certsdir" ] || return 0

    if [ -f "${certsdir}/certs.pem" ]
    then \
        echo -e "\e[33mWARNING: This functionality is maintained for retro-compatibility, but certificates synchronized in this step could be overwritten if anchors directory exists! Try to use anchors directory.\e[0m"
        cert-sync "${certsdir}/certs.pem"
    fi

    if find "${certsdir}/anchors" -mindepth 1 -name "*.crt" -quit;
    then \
        echo "Copying Trust Anchor certificates from ${certsdir}/anchors..." >&2
        for file in $(find "${certsdir}/anchors" -mindepth 1 -name "*.crt")
        do \
            echo "Copying certificate $file to /etc/pki/ca-trust/source/anchors/" >&2
            cp "$file" /etc/pki/ca-trust/source/anchors/
        done
        echo "Updating CA-Trust..."
        update-ca-trust
        echo "Syncing certs..."
        cert-sync <(cat /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem; echo; cat /etc/pki/ca-trust/extracted/pem/email-ca-bundle.pem)
    fi

    if find "${certsdir}/roots" -mindepth 1 -name "*.crt" -quit;
    then \
        echo "Importing Root CA certificates from ${certsdir}/roots..." >&2
        for file in $(find "${certsdir}/roots" -mindepth 1 -name "*.crt")
        do \
            echo "Importing certificate $file" >&2
            certmgr -add -c -m Trust "$file"
        done
    fi

    if find "${certsdir}/intermediates" -mindepth 1 -name "*.crt" -quit;
    then \
        echo "Importing Intermediate CA certificates from ${certsdir}/intermediates..." >&2
        for file in $(find "${certsdir}/intermediates" -mindepth 1 -name "*.crt")
        do \
            echo "Importing certificate $file" >&2
            certmgr -add -c -m CA "$file"
        done
    fi

    if find "${certsdir}/local" -mindepth 1 -name "*.crt" -quit;
    then \
        echo "Importing End Entity certificates from ${certsdir}/local..." >&2
        for file in $(find "${certsdir}/local" -mindepth 1 -name "*.crt")
        do \
            echo "Importing certificate $file" >&2
            certmgr -add -c -m My "$file"
        done
    fi

    if find "${certsdir}/local" -mindepth 1 -name "*.p12" -quit;
    then \
        echo "Importing End Entity certificate+key pairs from ${certsdir}/local..." >&2
        for file in $(find "${certsdir}/local" -mindepth 1 -name "*.p12")
        do \
            echo "Importing pkcs12 $file"
            passarg=""
            passfile=$(basename "$file" .p12).pass

            [ -f "${certsdir}/local/${passfile}" ] && passarg="-p $(cat ${certsdir}/local/${passfile})"
            certmgr -add -c $passarg -m My "$file"
        done
    fi
}


get_config_files()
{
    local configdir=$1
    local basedir=$2

    [ -d "$configdir" ] || return 0
    if find "$configdir" -mindepth 1 -name "*.config" -quit;
    then \
        echo "loading configuration files from config volume" >&2
        for file in $(find "$configdir" -mindepth 1 -name "*.config" -execdir echo {} ';')
        do \
            echo "Importing $file"
            [ -f "$basedir/$file" ] && rm -f "$basedir/$file"
            ln -s "$configdir/$file" "$basedir/$file"
        done
    fi
}

set_dnsserver()
{
    local dnsserver=$1

    if [ -n "${dnsserver}" ]
    then \
        echo "Setting DNS server to ${dnsserver}"
        if ! [[ ${dnsserver} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            dnsserver=$(getent hosts "${dnsserver}" | awk '{ print $1 }')
            [ -z "${dnsserver}" ] && print_error "Unable to resolve DNS server address." && exit 254
        fi
        sed -ci'' -e '/^nameserver .*/d' /etc/resolv.conf
        echo "nameserver ${dnsserver}" >> /etc/resolv.conf
    fi
}

which xmlstarlet || die 255 "Missing xmlstartlet binary."

# vim: ai ts=4 sw=4 noet sts=4 ft=sh
