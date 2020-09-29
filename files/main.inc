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
        echo "Syncing mono certificate store using certs.pem bundle.."
        cert-sync "${certsdir}/certs.pem"
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

which xmlstarlet || die 255 "Missing xmlstartlet binary."

# vim: ai ts=4 sw=4 noet sts=4 ft=sh
