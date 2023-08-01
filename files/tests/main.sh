#!/bin/bash

set -o errexit -o noclobber -o nounset -o pipefail

LC_ALL=C
LANG=C
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export LC_ALL LANG PATH

. ../main.inc

declare -x CONNSTRINGS="/tests/test1/connectionStrings.config"
upsert_connstr "provider1" "conn1" "testvalue1"
upsert_connstr "provider2" "conn2" "testvalue2"

CONNSTRINGS="/tests/test2/connectionStrings.config"
upsert_connstr "provider_setted" "conn1" "testvalue_setted"
upsert_connstr "provider2" "conn2" "testvalue2"

CONNSTRINGS="/tests/test3/connectionStrings.config"
set_connstr "conn1" "testvalue_setted"
upsert_connstr "provider2" "conn2" "testvalue2"